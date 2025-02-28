import SwiftUI
import Vision
import CoreML
import Combine

struct ImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()
    
    @State private var showResultSheet: Bool = false
    @State var detectedObjects: [Observation] = []
    @State var faceDetectedText: String = ""
    
    var item: Item
    var index: Int
    
    let model = try! YOLOv3Int8LUT(configuration: MLModelConfiguration())
    
    init(item: Item, index: Int) {
        self.item = item
        self.index = index
        imageLoader = ImageLoader(urlString: item.profile_image)
    }
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .onReceive(imageLoader.dataPublisher) { data in
                image = UIImage(data: data) ?? UIImage()
                DispatchQueue.main.async {
                    loadImage(profileImage: image)
                }
            }
        
        Text(faceDetectedText)
            .foregroundColor(.green)
    }
    
    func loadImage(profileImage: UIImage?) {
        let mlModel = model.model
        guard let vnCoreMLModel = try? VNCoreMLModel(for: mlModel) else { return }
        let request = VNCoreMLRequest(model: vnCoreMLModel) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            let defaults = UserDefaults.standard
            detectedObjects = results.map { result in
                guard let label = result.labels.first?.identifier else { return Observation(label: "", confidence: VNConfidence.zero, boundingBox: .zero) }
                let confidence = result.labels.first?.confidence ?? 0.0
                let boundedBox = result.boundingBox
                let faceDetected = (confidence * 100) > 90 && label == "person"
                let modelDataText: String
                if (faceDetected) {
                    faceDetectedText = "Face Detected"
                    modelDataText = "Face Detected with " + String(format:"%.2f", confidence * 100) + "% confidence"
                } else {
                    faceDetectedText = ""
                    modelDataText = "No Face Detected within Detected Objects"
                }
                defaults.set(modelDataText, forKey: "key" + String(index))
                let observation: Observation = Observation(label: label, confidence: confidence, boundingBox: boundedBox)
                return observation
            }
            if (detectedObjects.isEmpty) {
                defaults.set("No Objects were Detected", forKey: "key" + String(index))
            }
            print(detectedObjects)
            print(faceDetectedText)
        }
        guard let image = profileImage, let pixelBuffer = convertToCVPixelBuffer(newImage: image) else {
            return
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        do {
            try requestHandler.perform([request])
            showResultSheet.toggle()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

struct Observation {
    let label: String
    let confidence: VNConfidence
    let boundingBox: CGRect
}

func convertToCVPixelBuffer(newImage: UIImage) -> CVPixelBuffer? {
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer: CVPixelBuffer?
    CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)

    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

    context?.translateBy(x: 0, y: newImage.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)

    UIGraphicsPushContext(context!)
    newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    return pixelBuffer
}
