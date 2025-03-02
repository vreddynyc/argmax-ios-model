import SwiftUI
@preconcurrency import Vision
import CoreML
import Combine

@MainActor
class ViewModel: ObservableObject {
    
    @Published var userList: [Item] = []
    
    private var model = try! YOLOv3Int8LUT(configuration: MLModelConfiguration())
    
    func getItems() {
        guard let url = URL(string: "https://api.stackexchange.com/2.2/users?site=stackoverflow") else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let itemList = try! JSONDecoder().decode(ItemList.self, from: data!)
            print(itemList)
            
            DispatchQueue.main.async {
                self.userList = itemList.items
            }
        }
        .resume()
    }
    
    func analyzeImage(profileImage: UIImage, completion: @escaping (String) -> ()) {
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
            print(objectsResultsText)
            DispatchQueue.main.async {
                completion(objectsResultsText)
            }
        }
        let pixelBuffer = convertToCVPixelBuffer(newImage: profileImage)
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer!)

        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func convertToCVPixelBuffer(newImage: UIImage) -> CVPixelBuffer? {
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
}
