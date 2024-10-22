//
//  CardView.swift
//  SwipableCards
//
//  Created by Alireza Toghiani on 10/22/24.
//

import SwiftUI

// Move LikeDislike enum outside of CardView and remove 'private'
enum LikeDislike: Int {
    case like, dislike, superLike, none
}

struct CardView: View {
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: LikeDislike = .none

    private var user: User
    private var onRemove: (_ user: User, _ swipeStatus: LikeDislike) -> Void

    private let thresholdPercentage: CGFloat = 0.5 // Threshold for swipe action

    init(user: User, onRemove: @escaping (_ user: User, _ swipeStatus: LikeDislike) -> Void) {
        self.user = user
        self.onRemove = onRemove
    }

    /// Calculates horizontal swipe percentage relative to the card's width
    private func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }

    /// Calculates vertical swipe percentage relative to the card's height
    private func getVerticalGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.height / geometry.size.height
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color changes based on swipe status
                backgroundColor()
                    .cornerRadius(10)
                    .shadow(radius: 5)

                VStack(alignment: .leading) {
                    // Uncomment and modify the following lines if you have image assets
                    /*
                    Image(self.user.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
                        .clipped()
                    */

                    // User information
                    userInfo
                }
                .padding(.bottom)
            }
            .animation(.interactiveSpring(), value: translation)
            .offset(x: translation.width, y: translation.height)
            .rotationEffect(rotationAngle(geometry), anchor: .bottom)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        translation = value.translation

                        let horizontalPercentage = getGesturePercentage(geometry, from: value)
                        let verticalPercentage = getVerticalGesturePercentage(geometry, from: value)

                        if verticalPercentage <= -thresholdPercentage {
                            swipeStatus = .superLike
                        } else if horizontalPercentage >= thresholdPercentage {
                            swipeStatus = .like
                        } else if horizontalPercentage <= -thresholdPercentage {
                            swipeStatus = .dislike
                        } else {
                            swipeStatus = .none
                        }
                    }
                    .onEnded { value in
                        let horizontalPercentage = getGesturePercentage(geometry, from: value)
                        let verticalPercentage = getVerticalGesturePercentage(geometry, from: value)

                        if verticalPercentage <= -thresholdPercentage {
                            // Swipe Up - Super Like
                            onRemove(user, .superLike)
                        } else if abs(horizontalPercentage) > thresholdPercentage {
                            // Swipe Left or Right - Like or Dislike
                            onRemove(user, swipeStatus)
                        } else {
                            // Didn't meet threshold - reset
                            translation = .zero
                            swipeStatus = .none
                        }
                    }
            )
        }
    }

    // MARK: - Subviews and Helpers

    /// Returns the background color based on the swipe status
    private func backgroundColor() -> Color {
        switch swipeStatus {
        case .like:
            return Color.green.opacity(0.3)
        case .dislike:
            return Color.red.opacity(0.3)
        case .superLike:
            return Color.blue.opacity(0.3)
        case .none:
            return Color.white
        }
    }

    /// User information section
    private var userInfo: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(user.firstName) \(user.lastName), \(user.age)")
                        .font(.title)
                        .bold()
                    Text(user.occupation)
                        .font(.subheadline)
                        .bold()
                    Text("\(user.mutualFriends) Mutual Friends")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
    }

    /// Determines the rotation angle based on swipe status
    private func rotationAngle(_ geometry: GeometryProxy) -> Angle {
        if swipeStatus == .superLike {
            return .degrees(0)
        } else {
            return .degrees(Double(translation.width / geometry.size.width) * 25)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(
            user: User(
                id: 1,
                firstName: "Mark",
                lastName: "Bennett",
                age: 27,
                mutualFriends: 0,
                occupation: "Insurance Agent"
                // imageName: "profile_photo" // Uncomment if you have an image
            ),
            onRemove: { user, swipeStatus in
                // Handle the action based on swipeStatus
            }
        )
        .frame(height: 400)
        .padding()
    }
}
