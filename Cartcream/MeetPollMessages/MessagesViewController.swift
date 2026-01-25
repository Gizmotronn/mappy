import Messages
import SwiftUI

final class MessagesViewController: MSMessagesAppViewController {
    private let viewModel = PollViewModel()
    private var hostingController: UIHostingController<ContentView>?
    private var currentSession: MSSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let contentView = ContentView(
            viewModel: viewModel,
            onSend: { [weak self] in self?.sendPoll() },
            onRequestExpanded: { [weak self] in self?.requestPresentationStyle(.expanded) },
            onVote: { [weak self] placeId in self?.castVote(for: placeId) }
        )

        let hosting = UIHostingController(rootView: contentView)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(hosting)
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)
        hostingController = hosting
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if presentationStyle == .compact {
            requestPresentationStyle(.expanded)
        }
    }

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        if let url = conversation.selectedMessage?.url?.absoluteString {
            viewModel.debugInfo = "debug: willBecomeActive url=\(url)"
        } else {
            viewModel.debugInfo = "debug: willBecomeActive selectedMessage is nil"
        }
        loadPollIfNeeded(from: conversation.selectedMessage)
    }

    override func didBecomeActive(with conversation: MSConversation) {
        super.didBecomeActive(with: conversation)
        if let url = conversation.selectedMessage?.url?.absoluteString {
            viewModel.debugInfo = "debug: didBecomeActive url=\(url)"
        } else {
            viewModel.debugInfo = "debug: didBecomeActive selectedMessage is nil"
        }
        loadPollIfNeeded(from: conversation.selectedMessage)
    }

    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        super.didSelect(message, conversation: conversation)
        if let url = message.url?.absoluteString {
            viewModel.debugInfo = "debug: didSelect url=\(url)"
        } else {
            viewModel.debugInfo = "debug: didSelect url=nil"
        }
        loadPollIfNeeded(from: message)
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        if let message = activeConversation?.selectedMessage {
            loadPollIfNeeded(from: message)
        } else {
            viewModel.debugInfo = "debug: didTransition selectedMessage is nil"
        }
    }

    private func sendPoll() {
        guard let conversation = activeConversation else { return }
        let poll = viewModel.buildPoll()
        guard let url = PollCodec.encode(poll) else { return }

        let layout = MSMessageTemplateLayout()
        layout.caption = poll.title
        layout.subcaption = "\(poll.date.formattedShort()) • \(poll.places.count) places"
        layout.image = PollCardRenderer.render(poll: poll)

        let session = currentSession ?? MSSession()
        let message = MSMessage(session: session)
        message.layout = layout
        message.url = url
        currentSession = session

        conversation.send(message) { error in
            if let error = error {
                print("Failed to insert message: \(error)")
                DispatchQueue.main.async {
                    self.viewModel.statusMessage = "Couldn't send. Try again."
                }
            } else {
                DispatchQueue.main.async {
                    self.viewModel.statusMessage = "Poll sent."
                }
            }
        }
    }

    private func castVote(for placeId: UUID) {
        guard let conversation = activeConversation else { return }
        let voterId = conversation.localParticipantIdentifier.uuidString
        viewModel.toggleVote(placeId: placeId, voterId: voterId)
        let poll = viewModel.buildPoll()
        guard let url = PollCodec.encode(poll) else { return }

        let layout = MSMessageTemplateLayout()
        layout.caption = poll.title
        layout.subcaption = "\(poll.date.formattedShort()) • \(poll.places.count) places"
        layout.image = PollCardRenderer.render(poll: poll)

        let session = currentSession ?? MSSession()
        let message = MSMessage(session: session)
        message.layout = layout
        message.url = url
        currentSession = session

        conversation.send(message) { error in
            if let error = error {
                print("Failed to insert vote update: \(error)")
                DispatchQueue.main.async {
                    self.viewModel.statusMessage = "Couldn't update vote."
                }
            }
        }
    }

    private func loadPollIfNeeded(from message: MSMessage?) {
        guard let message else {
            viewModel.debugInfo = "debug: selectedMessage is nil"
            viewModel.isViewingPoll = false
            return
        }
        guard let url = message.url else {
            viewModel.debugInfo = "debug: message.url is nil"
            viewModel.isViewingPoll = false
            return
        }
        guard let poll = PollCodec.decode(from: url) else {
            viewModel.debugInfo = "debug: decode failed for url: \(url.absoluteString)"
            viewModel.isViewingPoll = false
            return
        }
        viewModel.debugInfo = "debug: loaded poll"
        viewModel.load(poll: poll)
        currentSession = message.session
    }
}

enum PollCardRenderer {
    static func render(poll: Poll, size: CGSize = CGSize(width: 1000, height: 360)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)

            UIColor.white.setFill()
            ctx.fill(rect)

            let cardRect = rect.insetBy(dx: 20, dy: 20)
            let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 28)
            UIColor(white: 0.95, alpha: 1.0).setFill()
            cardPath.fill()
            UIColor(white: 0.88, alpha: 1.0).setStroke()
            cardPath.lineWidth = 1
            cardPath.stroke()

            let dotRect = CGRect(x: cardRect.minX + 22, y: cardRect.minY + 18, width: 26, height: 26)
            let dot = UIBezierPath(ovalIn: dotRect)
            UIColor(red: 0.22, green: 0.52, blue: 0.32, alpha: 1.0).setFill()
            dot.fill()

            let title = poll.title
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            let titleRect = CGRect(x: cardRect.minX + 64, y: cardRect.minY + 16, width: cardRect.width - 92, height: 38)
            title.draw(in: titleRect, withAttributes: titleAttrs)

            let subtitle = "\(poll.date.formattedShort()) • \(poll.places.count) places"
            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .regular),
                .foregroundColor: UIColor(white: 0.45, alpha: 1.0)
            ]
            let subtitleRect = CGRect(x: cardRect.minX + 64, y: cardRect.minY + 54, width: cardRect.width - 92, height: 26)
            subtitle.draw(in: subtitleRect, withAttributes: subtitleAttrs)

            let optionStartY: CGFloat = cardRect.minY + 98
            let optionHeight: CGFloat = 34
            let maxOptions = min(poll.places.count, 4)
            for i in 0..<maxOptions {
                let place = poll.places[i]
                let y = optionStartY + CGFloat(i) * (optionHeight + 10)
                let votes = poll.votes[place.id.uuidString]?.count ?? 0
                let optionText = "\(place.name) • \(votes) votes"
                let optionAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 20, weight: .regular),
                    .foregroundColor: UIColor(white: 0.2, alpha: 1.0)
                ]
                let textRect = CGRect(x: cardRect.minX + 32, y: y, width: cardRect.width - 64, height: optionHeight)
                optionText.draw(in: textRect, withAttributes: optionAttrs)
            }

            let footer = "Open to vote in Messages"
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor(white: 0.55, alpha: 1.0)
            ]
            let footerRect = CGRect(x: cardRect.minX + 32, y: cardRect.maxY - 32, width: cardRect.width - 64, height: 20)
            footer.draw(in: footerRect, withAttributes: footerAttrs)
        }
    }
}
