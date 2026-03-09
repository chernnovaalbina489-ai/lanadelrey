import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var growthStage = 0
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            Color("Cream")
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Ellipse()
                        .fill(Color("EarthBrown").opacity(0.4))
                        .frame(width: 120, height: 30)
                        .offset(y: 50)

                    Circle()
                        .fill(Color("EarthBrown"))
                        .frame(width: 24, height: 24)
                        .offset(y: 30)
                        .opacity(growthStage == 0 ? 1 : 0)
                        .scaleEffect(growthStage == 0 ? 1 : 0.3)

                    VStack(spacing: 0) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color("LeafGreen"))
                            .rotationEffect(.degrees(-15))

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color("LeafGreen").opacity(0.7))
                            .frame(width: 4, height: 30)
                    }
                    .offset(y: -5)
                    .opacity(growthStage == 1 ? 1 : 0)
                    .scaleEffect(growthStage == 1 ? 1 : 0.3)

                    VStack(spacing: 0) {
                        ZStack {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color("LeafGreen"))
                                .rotationEffect(.degrees(-30))
                                .offset(x: -18, y: 10)

                            Image(systemName: "leaf.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color("LeafGreen").opacity(0.8))
                                .rotationEffect(.degrees(30))
                                .offset(x: 18, y: 10)

                            Image(systemName: "leaf.fill")
                                .font(.system(size: 38))
                                .foregroundStyle(Color("LeafGreen"))
                                .offset(y: -10)
                        }

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color("LeafGreen").opacity(0.7))
                            .frame(width: 6, height: 45)
                    }
                    .offset(y: -30)
                    .opacity(growthStage == 2 ? 1 : 0)
                    .scaleEffect(growthStage == 2 ? 1 : 0.3)
                }
                .frame(height: 160)
                .animation(.spring(response: 0.7, dampingFraction: 0.6), value: growthStage)

                VStack(spacing: 12) {
                    Text("Watch Your Garden Grow")
                        .font(.title.bold())
                        .foregroundStyle(Color("EarthBrown"))
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 15)

                    Text("Track your plants, schedule care,\nand capture their growth journey.")
                        .font(.body)
                        .foregroundStyle(Color("EarthBrown").opacity(0.7))
                        .multilineTextAlignment(.center)
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 15)
                }

                Spacer()

                Button {
                    withAnimation(AppAnimation.smooth) {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text("Start Growing")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color("LeafGreen"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PressableButtonStyle())
                .opacity(showButton ? 1 : 0)
                .scaleEffect(showButton ? 1 : 0.9)
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }

    private func startAnimationSequence() {
        growthStage = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { growthStage = 1 }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation { growthStage = 2 }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(AppAnimation.cardAppear) { showTitle = true }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            withAnimation(AppAnimation.cardAppear) { showSubtitle = true }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(AppAnimation.cardAppear) { showButton = true }
        }
    }
}

#Preview {
    OnboardingView()
}
