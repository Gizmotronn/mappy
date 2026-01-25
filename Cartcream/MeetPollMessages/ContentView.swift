import SwiftUI
import MapKit

struct ContentView: View {
    @ObservedObject var viewModel: PollViewModel
    var onSend: () -> Void
    var onRequestExpanded: () -> Void
    var onVote: (UUID) -> Void

    @State private var isSearchPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MeetPoll")
                .font(.headline.weight(.semibold))

            if viewModel.isViewingPoll {
                pollCardView
            } else {
                composeCardView
            }

            if let status = viewModel.statusMessage {
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let debug = viewModel.debugInfo {
                Text(debug)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground).ignoresSafeArea())
        .sheet(isPresented: $isSearchPresented) {
            PlaceSearchSheet { mapItem in
                viewModel.addPlace(from: mapItem)
            }
        }
    }

    private func openInMaps(_ place: PlaceOption) {
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name
        mapItem.openInMaps(launchOptions: nil)
    }
}

struct PlaceSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var searchService = PlaceSearchService()
    @State private var query: String = ""

    var onSelect: (MKMapItem) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(searchService.completions, id: \.self) { completion in
                    Button {
                        Task {
                            if let mapItem = await searchService.resolve(completion: completion) {
                                onSelect(mapItem)
                                dismiss()
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(completion.title)
                            Text(completion.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Place")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .searchable(text: $query)
            .onChange(of: query) { newValue in
                searchService.updateQuery(newValue)
            }
        }
    }
}

private extension ContentView {
    var composeCardView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Meeting")
                .font(.headline)
            TextField("Meeting name", text: $viewModel.title)
                .textFieldStyle(SkeuoFieldStyle())

            HStack {
                Text("Time")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                DatePicker("", selection: $viewModel.date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1)
                    )
            }

            Divider().background(Color(.separator))

            Text("Places")
                .font(.headline)

            if viewModel.places.isEmpty {
                Text("Add a few options")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.places) { place in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name).font(.headline)
                        Text(place.address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text("\(viewModel.voteCount(for: place.id)) votes")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Open in Maps") { openInMaps(place) }
                                .font(.footnote)
                        }
                    }
                    Divider().background(Color(.separator))
                }
            }

            HStack {
                Button("Add Place") {
                    onRequestExpanded()
                    isSearchPresented = true
                }
                .buttonStyle(SkeuoButtonStyle(base: Color(.systemBlue)))

                Spacer()

                Button("Send Poll") { onSend() }
                    .buttonStyle(SkeuoButtonStyle(base: Color(.systemBlue)))
                    .disabled(viewModel.places.isEmpty)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(.systemGray6), Color(.systemGray5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 10)
    }

    var pollCardView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.title.isEmpty ? "Meeting" : viewModel.title)
                .font(.headline)
            Text(viewModel.date.formattedShort())
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider().background(Color(.separator))

            ForEach(viewModel.places) { place in
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name).font(.headline)
                    Text(place.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Vote") { onVote(place.id) }
                            .buttonStyle(PillButtonStyle(fill: Color(.systemBlue), foreground: .white))
                        Text("\(viewModel.voteCount(for: place.id)) votes")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Open in Maps") { openInMaps(place) }
                            .font(.footnote)
                    }
                }
                Divider().background(Color(.separator))
            }

            Button("Create New Poll") { viewModel.reset() }
                .buttonStyle(PillButtonStyle(fill: Color(.systemGray4), foreground: .black))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct PillButtonStyle: ButtonStyle {
    let fill: Color
    let foreground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(fill.opacity(configuration.isPressed ? 0.85 : 1.0))
            )
    }
}

private struct SkeuoButtonStyle: ButtonStyle {
    let base: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                base.opacity(configuration.isPressed ? 0.85 : 1.0),
                                base.opacity(configuration.isPressed ? 0.75 : 0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 4)
    }
}

private struct SkeuoFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
