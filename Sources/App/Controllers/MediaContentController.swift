//
//  MediaContentController.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/9/25.
//

import Fluent
import NIOCore
import _NIOFileSystem
import Vapor

final class MediaContentController: RouteCollection {
    // req.application.directory.resourcesDirectory.appending("media")
    private let mediaDirectoryPath: String
    private let maxUploadSize: Int64 = 1024 * 1024 * 1024

    init(mediaPath: String) {
        self.mediaDirectoryPath = mediaPath
    }

    func boot(routes: Vapor.RoutesBuilder) throws {
        let mediaAPI = routes.grouped("api", "v2", "media")
        mediaAPI.on(.POST, "upload", body: .stream, use: uploadMedia)
        mediaAPI.group(":mediaID") { mediaItem in
            mediaItem.get(use: getMedia)
        }
    }
    
    func getMedia(req: Request) async throws -> Response {
        guard let mediaID = req.parameters.get("mediaID") else {
            throw Abort(.badRequest, reason: "No media ID provided")
        }
        guard let mediaID = UUID(mediaID),
            let userMedia = try await MediaContent.find(mediaID, on: req.db)
        else {
            throw Abort(.notFound)
        }
        let filePath = mediaDirectoryPath.appending(userMedia.filename)
        if let fileInfo = try? await FileSystem.shared.info(forFileAt: .init(filePath)) {
            req.logger.info("FileInfo: \(String(describing: fileInfo))")
        } else {
            req.logger.error("Could not open file at \(filePath)")
        }
        do {
            guard let mediaType = userMedia.mediaType() else {
                return try await req.fileio.asyncStreamFile(at: filePath)
            }
            return try await req.fileio.asyncStreamFile(at: filePath, mediaType: mediaType)
        } catch {
            req.logger.error("\(String(describing: error)) filePath: \(filePath)")
        }
        throw Abort(.internalServerError)
    }
    
    func uploadMedia(req: Request) async throws -> MediaContent {
        let payload = try req.jwt.verify(as: SessionJWTToken.self)
        guard let requestingUser = try await User.find(payload.userId, on: req.db) else {
            req.logger.info("Unauthorized upload attempt:\n\(req)")
            throw Abort(.unauthorized, reason: "Must be logged in")
        }
        guard let rawFilename = req.headers["File-Name"].first else {
            throw Abort(.badRequest, reason: "File-Name header missing or invalid")
        }
        // TODO: We really shouldn’t trust users with honest `Content-Type`s. Even if they aren’t malicious, they’re
        // busy and forgetful. This could lead to serious problems. For now, we can mitigate that this functionality
        // should be limited in its usefulness to authorized users. But still...
        guard let contentType = req.headers["Content-Type"].first else {
            throw Abort(.badRequest, reason: "Content-Type header is missing")
        }

        do {
            try FileManager.default.createDirectory(
                atPath: mediaDirectoryPath,
                withIntermediateDirectories: true
            )
        } catch {
            req.logger.error("Failed to create media directory: \(String(describing: error))")
            throw Abort(.internalServerError, reason: "Server misconfigured for file uploads")
        }
        let filename = UUID().uuidString
        let filePath = mediaDirectoryPath.appending(filename)
        try? FileManager.default.removeItem(atPath: filePath)
        guard FileManager.default.createFile(atPath: filePath,
                                       contents: nil,
                                       attributes: nil) else {
            req.logger.error("File creation failed for:\n\t \(filePath)")
            throw Abort(.internalServerError)
        }
        
        var streamedLength: Int64 = 0
        let fileSystem = FileSystem.shared
        let fileHandle = try await fileSystem.openFile(
            forWritingAt: FilePath(filePath),
            options: .modifyFile(createIfNecessary: true)
        )
        
        for try await byteBuffer in req.body {
            guard streamedLength < maxUploadSize else {
                try? await fileHandle.close()
                throw Abort(.badRequest, reason: "Upload exceeds maximum")
            }
            
            do {
                try await fileHandle.write(contentsOf: byteBuffer,
                                           toAbsoluteOffset: streamedLength)
                streamedLength += Int64(byteBuffer.readableBytes)
            } catch {
                try? await fileHandle.close()
                req.logger.error("\(error.localizedDescription)")
                throw Abort(.internalServerError, reason: "Failed to write to disk")
            }
        }
        do {
            try await fileHandle.close()
        } catch {
            req.logger.error("FileHandle failed to close for \(filePath)")
        }
        
        let media = try MediaContent(
            filename: filename,
            rawFilename: rawFilename,
            mimeType: contentType,
            contentLength: Int(streamedLength),
            userID: requestingUser
        )
        try await media.save(on: req.db)
        return media
    }
}
