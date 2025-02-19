
import SwiftUI

fileprivate enum Constants {
    static let contentVStackSpacing: CGFloat = 16
    static let imageVStackSpacinng: CGFloat = 8
    static let imageCornerRadius: CGFloat = 25
}

struct FlickrResultItem: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @State private var isPortrait: Bool = UIDevice.current.orientation.isPortrait
    @State private var shouldAnimate: Bool = false
    @State var item: FlickrItem
    
    private var frameHeightDivider: CGFloat {
        isPortrait ? 3 : 2
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.contentVStackSpacing) {
                    VStack(alignment: .leading, spacing: Constants.imageVStackSpacinng) {
                        FlickrImageView(url: item.media.imageString) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.rect(cornerRadius: Constants.imageCornerRadius))
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height / frameHeightDivider)
                                .accessibilityLabel("Photo title: \(item.title)")
                        } placeholder: {
                            ProgressView()
                                .accessibilityLabel("Loading image...")
                        }
                        HStack(alignment: .top) {
                            Text("Height: \(item.imageDimensions.height), Width: \(item.imageDimensions.height)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .dynamicTypeSize(...dynamicTypeSize)
                                .accessibilityLabel("Height of image: \(item.imageDimensions.height), Width of Image: \(item.imageDimensions.height)")
                            Spacer()
                            Text(item.dateTaken.formatDate())
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .dynamicTypeSize(...dynamicTypeSize)
                                .accessibilityLabel("Image date: \(item.dateTaken.formatDate())")
                        }
                    }
                    
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .dynamicTypeSize(...dynamicTypeSize)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Author: \(item.author)")
                        .font(.title2)
                        .dynamicTypeSize(...dynamicTypeSize)
                        .accessibilityLabel("Author name: \(item.author)")
                    
                    Divider()
                    
                    Text($item.formattedDescription.wrappedValue)
                        .font(.subheadline)
                        .dynamicTypeSize(...dynamicTypeSize)
                        .accessibilityLabel("Description: \($item.formattedDescription.wrappedValue)")
                         
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeIn, value: shouldAnimate)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
        .onAppear {
            updateOrientation()
            shouldAnimate = true
            Task {
                item.formattedDescription = item.description.htmlToPlainText()
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIDevice.orientationDidChangeNotification
        )) { _ in
            updateOrientation()
        }
    }
    
    private var shareButton: some View {
       ShareLink(
           item: item.link,
           subject: Text(item.title),
           message: Text("Sharing this image from Flickr")
       )
       .disabled(item.link.isEmpty)
       .accessibilityLabel("Share image")
   }
    
    private func updateOrientation() {
        let orientation = UIDevice.current.orientation
        if orientation.isValidInterfaceOrientation {
            isPortrait = orientation.isPortrait
        }
    }
}
