# AI Integration Plan

## Overview

The core feature of the Organizer app is AI-powered duplicate detection. When a user takes a photo of an item, the app analyzes it and checks against existing items in their inventory to find duplicates or similar items.

## AI Service Options

### Option 1: On-Device ML (TensorFlow Lite)
**Pros:**
- Privacy-friendly (no data sent to cloud)
- Works offline
- Fast response time
- No API costs

**Cons:**
- Larger app size
- Limited model complexity
- Device resource intensive
- Requires model training/optimization

**Implementation:**
- Use `tflite_flutter` package
- Load pre-trained image similarity model
- Extract feature vectors from images
- Compare vectors using cosine similarity

### Option 2: Google ML Kit (Recommended for MVP)
**Pros:**
- Easy to integrate
- Good accuracy
- Built-in image labeling
- Object detection

**Cons:**
- Requires internet for some features
- Limited customization
- Rate limits on free tier

**Implementation:**
- Use `google_ml_kit` package
- Image labeling for categorization
- Custom similarity comparison logic

### Option 3: Cloud-Based APIs (OpenAI, Google Vision, AWS Rekognition)
**Pros:**
- Most accurate
- Powerful features
- Regular updates
- No device limitations

**Cons:**
- Requires internet
- API costs
- Privacy concerns
- Latency

**Implementation:**
- REST API calls
- Image upload to cloud
- Response parsing
- Error handling

### Option 4: Hybrid Approach (Recommended for Production)
**Pros:**
- Best of both worlds
- Fallback mechanisms
- Flexible based on context

**Cons:**
- More complex implementation
- Requires both solutions

**Implementation:**
- On-device for quick checks
- Cloud API for uncertain matches
- User preference settings

## Recommended Implementation Strategy

### Phase 1: MVP with Google ML Kit
Start with Google ML Kit for rapid development:

```dart
// services/ai/ai_service.dart
class AIService {
  // Extract labels and features from image
  Future<ImageAnalysis> analyzeImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final imageLabeler = ImageLabeler();
    final labels = await imageLabeler.processImage(inputImage);
    
    return ImageAnalysis(
      labels: labels.map((l) => l.label).toList(),
      confidence: labels.map((l) => l.confidence).toList(),
    );
  }
  
  // Find similar items in inventory
  Future<List<SimilarityResult>> findSimilarItems(
    String imagePath,
    List<Item> inventory,
  ) async {
    final newImageAnalysis = await analyzeImage(imagePath);
    final results = <SimilarityResult>[];
    
    for (final item in inventory) {
      for (final existingImagePath in item.imageUrls) {
        final existingAnalysis = await analyzeImage(existingImagePath);
        final similarity = calculateSimilarity(
          newImageAnalysis,
          existingAnalysis,
        );
        
        if (similarity > 0.7) { // 70% threshold
          results.add(SimilarityResult(
            item: item,
            confidence: similarity,
          ));
        }
      }
    }
    
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results.take(5).toList(); // Top 5 matches
  }
  
  // Calculate similarity between two analyses
  double calculateSimilarity(
    ImageAnalysis a,
    ImageAnalysis b,
  ) {
    // Simple label overlap approach
    final commonLabels = a.labels.toSet().intersection(b.labels.toSet());
    final totalLabels = a.labels.toSet().union(b.labels.toSet());
    
    if (totalLabels.isEmpty) return 0.0;
    
    return commonLabels.length / totalLabels.length;
  }
}
```

### Phase 2: Enhanced with TensorFlow Lite
Add more sophisticated similarity detection:

```dart
class TFLiteService {
  late Interpreter _interpreter;
  
  Future<void> initialize() async {
    _interpreter = await Interpreter.fromAsset('models/mobilenet_v2.tflite');
  }
  
  Future<List<double>> extractFeatures(String imagePath) async {
    // Load and preprocess image
    final image = await loadImage(imagePath);
    final input = preprocessImage(image);
    
    // Run inference
    var output = List.filled(1280, 0.0).reshape([1, 1280]);
    _interpreter.run(input, output);
    
    return output[0];
  }
  
  double cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
```

### Phase 3: Cloud Enhancement
Add cloud API for difficult cases:

```dart
class CloudAIService {
  Future<List<SimilarityResult>> cloudAnalysis(
    String imagePath,
    List<Item> inventory,
  ) async {
    // Upload image to cloud storage
    final imageUrl = await uploadImage(imagePath);
    
    // Call cloud API (e.g., Google Vision API)
    final response = await http.post(
      Uri.parse('https://vision.googleapis.com/v1/images:annotate'),
      headers: {'Authorization': 'Bearer $apiKey'},
      body: jsonEncode({
        'requests': [{
          'image': {'source': {'imageUri': imageUrl}},
          'features': [
            {'type': 'LABEL_DETECTION'},
            {'type': 'OBJECT_LOCALIZATION'},
            {'type': 'IMAGE_PROPERTIES'},
          ],
        }],
      }),
    );
    
    // Process results and compare with inventory
    return processCloudResults(response, inventory);
  }
}
```

## Feature Vector Storage

Store feature vectors with items for faster comparison:

```dart
class Item {
  // Existing fields...
  
  // AI-related fields
  List<double>? featureVector; // For TFLite
  List<String>? labels;        // For ML Kit
  Map<String, double>? labelConfidence;
  
  // Cache analysis results
  DateTime? lastAnalyzed;
}
```

## User Experience Flow

### 1. Quick Scan Mode
```
User opens camera → Takes photo → 
Processing indicator → 
Results shown immediately (if matches found) →
Option to add item or view similar items
```

### 2. Detailed Scan Mode
```
User opens camera → Takes photo →
Processing indicator →
Show top matches with confidence scores →
User can view each match detail →
Confirm if same/different →
Add to inventory if new
```

### 3. Offline Mode
```
Photo captured → Saved to queue →
Processing when online →
Notification when results ready
```

## Performance Optimization

1. **Image Preprocessing:**
   - Resize images to 224x224 or 299x299
   - Normalize pixel values
   - Cache preprocessed images

2. **Batch Processing:**
   - Compare against similar categories first
   - Use indexed searches
   - Limit comparison scope

3. **Caching:**
   - Cache feature vectors
   - Cache analysis results
   - Update only when image changes

4. **Background Processing:**
   - Use isolates for heavy computation
   - Show progress indicators
   - Allow cancellation

## Privacy & Data Handling

1. **On-Device Processing:**
   - Default to on-device when possible
   - No data sent without consent

2. **Cloud Processing:**
   - Clear user consent
   - Encrypted transmission
   - Temporary storage only
   - Delete after processing

3. **Data Storage:**
   - Encrypted local storage
   - User controls data deletion
   - Export functionality

## Testing Strategy

1. **Unit Tests:**
   - Test similarity algorithms
   - Test feature extraction
   - Test threshold values

2. **Integration Tests:**
   - Test full AI pipeline
   - Test with various image types
   - Test edge cases

3. **User Testing:**
   - Test with real items
   - Measure accuracy
   - Gather feedback on threshold values

## Future Enhancements

1. **Barcode/QR Code Recognition**
2. **Text Recognition (OCR) for labels**
3. **Color-based similarity**
4. **Shape recognition**
5. **Brand/Logo detection**
6. **Price comparison integration**
7. **AR preview in store**
