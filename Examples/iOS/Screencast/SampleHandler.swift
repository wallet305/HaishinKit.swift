import HaishinKit
import VideoToolbox
import ReplayKit
import Logboard

@available(iOS 10.0, *)
open class SampleHandler: RPBroadcastSampleHandler {
    private var broadcaster: RTMPBroadcaster = RTMPBroadcaster()

    override open func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        let logger = Logboard.with(HaishinKitIdentifier)
        let socket = SocketAppender()
        socket.connect("192.168.11.15", port: 22222)
        logger.level = .debug
        logger.appender = socket

        broadcaster.streamName = "live"
        broadcaster.connect("rtmp://test:test@192.168.11.15/live", arguments: nil)
    }

    override open func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            // 296x640
            if let description: CMVideoFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let dimensions: CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(description)
                broadcaster.stream.videoSettings = [
                    "width": 296,
                    "height": 640,
                    "bitrate": 540 * 1024,
                    "profileLevel": kVTProfileLevel_H264_Baseline_3_1,
                ]
            }
            broadcaster.appendSampleBuffer(sampleBuffer, withType: .video)
        case .audioApp:
            break
        case .audioMic:
            broadcaster.appendSampleBuffer(sampleBuffer, withType: .audio)
        }
    }
}
