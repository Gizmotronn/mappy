// CheckInOverlay.swift
// Mappy
// Created by Liam Arbuckle on 15/1/2026.

import SwiftUI
import MapKit

struct CheckInOverlay: View {
    @Binding var isExpanded: Bool
    var onCheckIn: (() -> Void)?
    @StateObject private var searchService = CheckInLocationSearchService()
    @State private var lastCheckIn: CheckIn?
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                CheckInExpandedView(searchService: searchService, onCheckIn: { checkIn in
                    lastCheckIn = checkIn
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            isExpanded = false
                        }
                    }
                })
                .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
            } else {
                Button(action: {
                    withAnimation {
                        isExpanded = true
                    }
                }) {
                    Text("Check In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .padding(.horizontal, 0)
        .padding(.bottom, 0)
    }
}

// Helper for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 16.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    @State var expanded = false
    return CheckInOverlay(isExpanded: $expanded)
}
