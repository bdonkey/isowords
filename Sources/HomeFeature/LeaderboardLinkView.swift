import ComposableArchitecture
import LeaderboardFeature
import SharedModels
import Styleguide
import SwiftUI

struct LeaderboardLinkView: View {
  @Environment(\.colorScheme) var colorScheme
  let store: Store<HomeState, HomeAction>
  @ObservedObject var viewStore: ViewStore<ViewState, HomeAction>

  struct ViewState: Equatable {
    var tag: AppRoute.Tag?
    var weekInReview: FetchWeekInReviewResponse?

    init(state: HomeState) {
      self.tag = state.route?.tag
      self.weekInReview = state.weekInReview
    }
  }

  init(store: Store<HomeState, HomeAction>) {
    self.store = store
    self.viewStore = ViewStore(self.store.scope(state: ViewState.init(state:)))
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .firstTextBaseline) {
        Text("Leaderboards")
          .adaptiveFont(.matterMedium, size: 16)
          .padding(.bottom)

        Spacer()

        Button("View all") {
          self.viewStore.send(.setNavigation(tag: self.tag))
        }
        .adaptiveFont(.matterMedium, size: 12)
      }
      .foregroundColor(self.colorScheme == .dark ? .hex(0xE79072) : .isowordsBlack)

      NavigationLink(
        destination: self.destination,
        tag: self.tag,
        selection: self.viewStore.binding(
          get: \.tag,
          send: HomeAction.setNavigation(tag:)
        )
        .animation()
      ) {
        VStack(alignment: .leading, spacing: .grid(4)) {
          Text("Week in review")

          Divider()
            .frame(height: 2)
            .background(self.colorScheme == .dark ? Color.isowordsBlack : .hex(0xE26C5E))

          self.weekInReview(self.viewStore.weekInReview)
            .adaptiveFont(.matterMedium, size: 14)
        }
      }
      .buttonStyle(
        LeaderboardLinkButtonStyle(
          backgroundColor: self.colorScheme == .dark ? .hex(0xE26C5E) : .isowordsBlack,
          foregroundColor: self.colorScheme == .dark ? .isowordsBlack : .hex(0xE26C5E)
        )
      )
    }
  }

  var tag: AppRoute.Tag { .leaderboard }

  var destination: some View {
    IfLetStore(
      self.store.scope(
        state: (\HomeState.route).appending(path: /AppRoute.leaderboard).extract(from:),
        action: HomeAction.leaderboard
      ),
      then: LeaderboardView.init(store:)
    )
  }

  func weekInReview(_ weekInReview: FetchWeekInReviewResponse?) -> some View {
    VStack(spacing: .grid(1)) {
      HStack {
        Text("Timed")
        Spacer()
        if let timedRank = weekInReview?.timedRank {
          Text("\(timedRank.rank) of \(timedRank.outOf)")
        } else {
          Text("-")
        }
      }
      HStack {
        Text("Unlimited")
        Spacer()
        if let unlimitedRank = weekInReview?.unlimitedRank {
          Text("\(unlimitedRank.rank) of \(unlimitedRank.outOf)")
        } else {
          Text("-")
        }
      }
      HStack {
        Text("Best word")
        Spacer()
        HStack(alignment: .top, spacing: 0) {
          if let word = weekInReview?.word {
            Text(word.letters.capitalized)
            Text("\(word.score)")
              .padding(.top, -2)
              .adaptiveFont(.matterMedium, size: 10)
          } else {
            Text("-")
          }
        }
      }
    }
  }
}

public struct LeaderboardLinkButtonStyle: ButtonStyle {
  let backgroundColor: Color
  let foregroundColor: Color
  let isActive: Bool

  public init(
    backgroundColor: Color = .adaptiveBlack,
    foregroundColor: Color = .adaptiveWhite,
    isActive: Bool = true
  ) {
    self.backgroundColor = backgroundColor
    self.foregroundColor = foregroundColor
    self.isActive = isActive
  }

  public func makeBody(configuration: Self.Configuration) -> some View {
    return configuration.label
      .foregroundColor(
        self.foregroundColor
          .opacity(!configuration.isPressed ? 1 : 0.5)
      )
      .padding([.leading, .top, .trailing], .grid(5))
      .padding(.bottom, .grid(7))
      .background(
        RoundedRectangle(cornerRadius: 13)
          .fill(
            self.backgroundColor
              .opacity(self.isActive && !configuration.isPressed ? 1 : 0.5)
          )
      )
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .adaptiveFont(.matterMedium, size: 16)
  }
}

#if DEBUG
  import SwiftUIHelpers

  struct LeaderboardLinkView_Previews: PreviewProvider {
    static var previews: some View {
      Preview {
        LeaderboardLinkView(
          store: Store(
            initialState: .init(),
            reducer: .empty,
            environment: ()
          )
        )
      }
    }
  }
#endif
