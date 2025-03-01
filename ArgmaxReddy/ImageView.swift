import SwiftUI
import Vision
import CoreML
import Combine
import Kingfisher

struct ImageView: View {
    
    @State private var image: UIImage = UIImage()
    @State private var faceDetectedText: String = ""
    
    private var user: Item
    private var index: Int
    
    private let model = try! YOLOv3Int8LUT(configuration: MLModelConfiguration())
    
    init(item: Item, index: Int) {
        self.user = item
        self.index = index
    }
    
    var body: some View {        
        VStack {
            KFImage(URL(string: user.profile_image))
                .onSuccess { result in
                    print("Image loaded successfully: \(result.cacheType)")
//                    DispatchQueue.main.async {
//                        analyzeImage(profileImage: result.image)
//                    }
                }
                .onFailure { error in
                    print("Image failed to load: \(error.localizedDescription)")
                }
                .onProgress { receivedSize, totalSize in
                    print("Loading progress: \(receivedSize)/\(totalSize)")
                }
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
        
        Text(faceDetectedText)
            .foregroundColor(.green)
    }
    
    func analyzeImage(profileImage: UIImage?) {
        let mlModel = model.model
        guard let vnCoreMLModel = try? VNCoreMLModel(for: mlModel) else { return }
        let request = VNCoreMLRequest(model: vnCoreMLModel) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            var objectsResultsText = ""
            var resultFaceDetected = ""
            results.forEach { result in
                let label = result.labels.first?.identifier ?? ""
                let confidence = result.labels.first?.confidence ?? 0.0
                if ((confidence * 100) > 95 && label == "person") {
                    resultFaceDetected = "Face Detected"
                }
                let confidenceText = String(format:"%.2f", confidence * 100)
                let resultText = "Label: " + label + ", Confidence: " + confidenceText + "\n"
                print(resultText)
                objectsResultsText += resultText
            }
            print(resultFaceDetected)
            faceDetectedText = resultFaceDetected
            let defaults = UserDefaults.standard
            if (results.isEmpty) {
                defaults.set("No Objects were Detected", forKey: "key" + String(index))
            } else {
                defaults.set(objectsResultsText, forKey: "key" + String(index))
            }
            print(objectsResultsText)
        }
        let pixelBuffer = convertToCVPixelBuffer(newImage: image)
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer!)
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
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
