//
//  ProfileView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Dedicated Profile & Account Management screen containing:
/// - Customizable Avatar / Profile Picture & Hunter Identity
/// - Hunter Level & EXP Progression
/// - Visual HUD Theme Selector (Theme 1 & Theme 3)
/// - System Settings: Terms & Conditions, Privacy, Logout, and Delete Account.
@MainActor
public struct ProfileView: View {
    @State private var profileManager = ProfileManager.shared
    @State private var isEditing = false

    // Editable draft fields
    @State private var draftName = ""
    @State private var draftTitle = ""
    @State private var draftJob = ""
    @State private var draftBio = ""
    @State private var selectedAvatarIcon = "crown.fill"

    // Sheet and Alert presentation states
    @State private var showSaveConfirmation = false
    @State private var showTermsSheet = false
    @State private var showPrivacySheet = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false

    private let availableAvatars = [
        "crown.fill",
        "shield.fill",
        "bolt.fill",
        "flame.fill",
        "eye.fill",
        "figure.run",
        "star.fill"
    ]

    public init() {}

    public var body: some View {
        ZStack {
            Color.systemBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    identityCard
                    levelProgressionCard
                    themeSettingsSection
                    systemAccountSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 110) // Safe area breathing room above floating tab dock
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            syncDraftWithCurrentProfile()
        }
        .sheet(isPresented: $showTermsSheet) {
            termsAndConditionsSheet
        }
        .sheet(isPresented: $showPrivacySheet) {
            privacyPolicySheet
        }
        .alert("DISCONNECT FROM SYSTEM?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                SystemHaptics.shared.selectionTick()
            }
        } message: {
            Text("Are you sure you want to log out of your current Hunter terminal session?")
        }
        .alert("DELETE HUNTER PROFILE?", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Account", role: .destructive) {
                SystemHaptics.shared.selectionTick()
            }
        } message: {
            Text("WARNING: This will permanently erase your Hunter awakening data, stat allocations, quest streaks, and vault gold. This action cannot be undone.")
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.systemPrimary)
                    .frame(width: 8, height: 8)
                    .shadow(color: Color.systemPrimaryGlow, radius: 4)

                Text("[HUNTER DOSSIER // ACCOUNT SETTINGS]")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
            }

            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if isEditing {
                        syncDraftWithCurrentProfile()
                        isEditing = false
                    } else {
                        syncDraftWithCurrentProfile()
                        isEditing = true
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: isEditing ? "xmark" : "pencil")
                        .font(.system(size: 11, weight: .bold))
                    Text(isEditing ? "CANCEL" : "EDIT")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                }
                .foregroundColor(isEditing ? .gray : Color.systemPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.systemCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.systemBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Identity Card & Profile Picture

    private var identityCard: some View {
        let profile = profileManager.profile

        return VStack(spacing: 16) {
            if !isEditing {
                // View Mode
                HStack(alignment: .center, spacing: 14) {
                    // Profile Picture / Avatar Emblem
                    ZStack {
                        Circle()
                            .fill(Color.systemPrimary.opacity(0.15))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle().stroke(Color.systemPrimary, lineWidth: 2)
                            )
                            .shadow(color: Color.systemPrimaryGlow.opacity(0.6), radius: 6)

                        Image(systemName: selectedAvatarIcon)
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(Color.systemPrimary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.name)
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemTextPrimary)

                        HStack(spacing: 6) {
                            Text(profile.title.uppercased())
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(Color.systemPrimary)

                            Text("•")
                                .foregroundColor(Color.systemTextSecondary)

                            Text(profile.job.uppercased())
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.systemSecondary)
                        }

                        Text("\(profile.rank.rawValue) Hunter • Level \(profile.level)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.systemTextSecondary)
                    }

                    Spacer()
                }

                // Personal Directive / Bio
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 9))
                            .foregroundColor(Color.systemPrimary)
                        Text("PERSONAL DIRECTIVE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)
                    }

                    Text(profile.bio)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.systemTextPrimary)
                        .italic()
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.systemCard.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            } else {
                // Edit Mode
                VStack(spacing: 14) {
                    HStack {
                        Text("UPDATE HUNTER DETAILS")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)
                        Spacer()
                    }

                    // Avatar Selection Row
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SELECT PROFILE EMBLEM")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(availableAvatars, id: \.self) { avatar in
                                    let isSelected = selectedAvatarIcon == avatar

                                    Button(action: {
                                        selectedAvatarIcon = avatar
                                        SystemHaptics.shared.selectionTick()
                                    }) {
                                        Image(systemName: avatar)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(isSelected ? .black : Color.systemPrimary)
                                            .frame(width: 40, height: 40)
                                            .background(isSelected ? Color.systemPrimary : Color.systemCard)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(Color.systemPrimary.opacity(0.6), lineWidth: isSelected ? 2 : 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    // Name Input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HUNTER NAME")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)
                        TextField("Name", text: $draftName)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color.systemTextPrimary)
                            .padding(10)
                            .background(Color.systemCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemBorder, lineWidth: 1))
                    }

                    // Title Input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HUNTER TITLE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)
                        TextField("Title (e.g. Shadow Monarch)", text: $draftTitle)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color.systemTextPrimary)
                            .padding(10)
                            .background(Color.systemCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemBorder, lineWidth: 1))
                    }

                    // Job Input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("JOB / CLASS")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)
                        TextField("Class (e.g. Necromancer)", text: $draftJob)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color.systemTextPrimary)
                            .padding(10)
                            .background(Color.systemCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemBorder, lineWidth: 1))
                    }

                    // Bio Input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PERSONAL DIRECTIVE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)
                        TextField("Directive / Motto", text: $draftBio)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color.systemTextPrimary)
                            .padding(10)
                            .background(Color.systemCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.systemBorder, lineWidth: 1))
                    }

                    // Save Button
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            profileManager.updateDetails(
                                name: draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? profile.name : draftName,
                                title: draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? profile.title : draftTitle,
                                job: draftJob.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? profile.job : draftJob,
                                bio: draftBio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? profile.bio : draftBio
                            )
                            isEditing = false
                            showSaveConfirmation = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("SAVE PROFILE")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.systemPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: Color.systemPrimaryGlow.opacity(0.6), radius: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }

            if showSaveConfirmation {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                    Text("Profile details updated successfully")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(Color.systemPrimary)
                .transition(.opacity)
            }
        }
        .padding(16)
        .holographicCard(cornerRadius: 16)
    }

    // MARK: - Level Progression Card

    private var levelProgressionCard: some View {
        let profile = profileManager.profile

        return VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    RankBadgeView(rank: profile.rank, showTitle: false, size: .small)
                    Text("LEVEL \(profile.level) PROGRESSION")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemTextPrimary)
                }

                Spacer()

                Text("\(profile.currentExp) / \(profile.expRequiredForNextLevel) EXP")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.systemCard)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [ThemeManager.shared.palette.expGradientStart, ThemeManager.shared.palette.expGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * profile.expProgressPercentage, 8))
                        .shadow(color: Color.systemPrimaryGlow.opacity(0.6), radius: 5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: profile.expProgressPercentage)
                }
            }
            .frame(height: 8)

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.systemGateAmber)
                    Text("\(profile.currentStreakDays)d Streak")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemTextSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.systemGateAmber)
                    Text("\(profile.gold) Gold in Vault")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.systemGateAmber)
                }
            }
            .padding(.top, 2)
        }
        .padding(14)
        .holographicCard(cornerRadius: 16)
    }

    // MARK: - Theme Settings Section

    private var themeSettingsSection: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color.systemPrimary)
                    Text("VISUAL HUD THEME")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemTextPrimary)
                }

                Spacer()
            }

            VStack(spacing: 10) {
                ForEach(SystemTheme.allCases) { theme in
                    let isSelected = ThemeManager.shared.currentTheme == theme

                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            ThemeManager.shared.switchTheme(to: theme)
                        }
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.systemPrimary : Color.systemCard)
                                    .frame(width: 36, height: 36)

                                Image(systemName: theme.iconSystemName)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(isSelected ? .black : Color.systemTextSecondary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(theme.displayName)
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(Color.systemTextPrimary)

                                Text(theme.subtitle)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color.systemTextSecondary)
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.systemPrimary)
                            }
                        }
                        .padding(12)
                        .background(Color.systemCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.systemPrimary : Color.systemBorder, lineWidth: isSelected ? 1.5 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 16)
    }

    // MARK: - Account & System Controls Section

    private var systemAccountSection: some View {
        VStack(spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color.systemPrimary)
                    Text("SYSTEM SETTINGS & LEGAL")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemTextPrimary)
                }

                Spacer()
            }

            VStack(spacing: 6) {
                // Terms & Conditions Button
                accountMenuRow(title: "Terms & Conditions", icon: "doc.text.fill") {
                    showTermsSheet = true
                }

                // Privacy Policy Button
                accountMenuRow(title: "Privacy Policy", icon: "hand.raised.fill") {
                    showPrivacySheet = true
                }

                // Log Out
                accountMenuRow(title: "Disconnect / Log Out", icon: "rectangle.portrait.and.arrow.right", isDestructive: false) {
                    showLogoutAlert = true
                }

                // Delete Account
                accountMenuRow(title: "Erase Profile & Delete Account", icon: "trash.fill", isDestructive: true) {
                    showDeleteAccountAlert = true
                }
            }

            // Version Telemetry
            Text("SYSTEM: AWAKENING // BUILD v2.5.0 (HUNTER GUILD EDITION)")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(Color.systemTextSecondary.opacity(0.8))
                .padding(.top, 6)
        }
        .padding(14)
        .holographicCard(cornerRadius: 16)
    }

    private func accountMenuRow(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isDestructive ? .systemPenaltyCrimson : Color.systemPrimary)
                    .frame(width: 20)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isDestructive ? .systemPenaltyCrimson : Color.systemTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.systemTextSecondary)
            }
            .padding(12)
            .background(Color.systemCard.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isDestructive ? Color.systemPenaltyCrimson.opacity(0.3) : Color.systemBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Terms & Conditions Sheet

    private var termsAndConditionsSheet: some View {
        NavigationStack {
            ZStack {
                Color.systemBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("SYSTEM DIRECTIVE TERMS & CONDITIONS")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)

                        Text("1. Hunter Awakening Protocol")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.systemTextPrimary)
                        Text("By accepting the System Directive, the Hunter agrees to complete daily physical and focus directives. Failure to fulfill required objectives prior to midnight local time initiates dimensional exile into the Penalty Zone.")
                            .font(.system(size: 11))
                            .foregroundColor(Color.systemTextSecondary)

                        Text("2. Economy & System Shop")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.systemTextPrimary)
                        Text("Gold rewards deposited into the Vault are earned via authentic effort. Real-world reward redemptions are subject to Hunter honor codes and personal discipline.")
                            .font(.system(size: 11))
                            .foregroundColor(Color.systemTextSecondary)

                        Text("3. Data Sovereignty")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.systemTextPrimary)
                        Text("All progression sheets, habits, and attribute matrices are stored locally on your device. Erasing your profile is permanent.")
                            .font(.system(size: 11))
                            .foregroundColor(Color.systemTextSecondary)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Terms & Conditions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        showTermsSheet = false
                    }
                    .foregroundColor(Color.systemPrimary)
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Privacy Policy Sheet

    private var privacyPolicySheet: some View {
        NavigationStack {
            ZStack {
                Color.systemBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("HUNTER DATA PRIVACY POLICY")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)

                        Text("1. Zero Third-Party Telemetry")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.systemTextPrimary)
                        Text("System: Awakening does not track, sell, or broadcast personal habit logs or biometric metrics to external guild syndicates. Your awakening is yours alone.")
                            .font(.system(size: 11))
                            .foregroundColor(Color.systemTextSecondary)

                        Text("2. Secure Local Persistence")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.systemTextPrimary)
                        Text("All Hunter Profile data, streak counts, and custom real-world rewards are encrypted and stored solely within the sandboxed local application store.")
                            .font(.system(size: 11))
                            .foregroundColor(Color.systemTextSecondary)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        showPrivacySheet = false
                    }
                    .foregroundColor(Color.systemPrimary)
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Helpers

    private func syncDraftWithCurrentProfile() {
        let p = profileManager.profile
        draftName = p.name
        draftTitle = p.title
        draftJob = p.job
        draftBio = p.bio
    }
}

#Preview {
    ProfileView()
}
