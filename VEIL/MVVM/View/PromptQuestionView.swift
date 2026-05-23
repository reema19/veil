//
//  PromptQuestionView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
import SwiftUI

struct PromptQuestionView: View {
    
    @ObservedObject var viewModel: PromptViewModel
    var onDismiss: () -> Void = {}

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Header
                HStack(alignment: .center, spacing: 12) {
                    Button(action: onDismiss) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("TitleColor").opacity(0.7))
                        }
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.sessionTitle)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("TitleColor"))
                        Text(viewModel.sessionSubtitle)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color("SubtitleColor"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // MARK: - Section Title
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.sectionTitle)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("TitleColor"))
                        Text(viewModel.sectionSubtitle)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color("SubtitleColor"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                Spacer()
                
                // MARK: - Question
                Text(viewModel.currentPrompt.question)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(Color("SubtitleColor"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .animation(.easeInOut, value: viewModel.currentPromptIndex)
                
                Spacer()
                Spacer()
                
                // MARK: - Progress
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.totalPrompts, id: \.self) { i in
                            Circle()
                                .fill(i == viewModel.currentPromptIndex
                                      ? Color("TitleColor")
                                      : Color("DotInactive"))
                                .frame(width: 8, height: 8)
                        }
                    }
                    Text(viewModel.promptLabel)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color("SubtitleColor"))
                }
                
                Spacer()
                
                // MARK: - Actions
                VStack(spacing: 12) {
                    Button(action: { viewModel.tryAnother() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.black)
                            Text("Try another")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.black)
                        }
                        .frame(width: 234, height: 34)
                        .background(Color.white)
                        .cornerRadius(40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.black, lineWidth: 1)
                        )
                    }
                    
                    Button(action: { viewModel.stayWithThis() }) {
                        Text("Stay with this")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .frame(width: 234, height: 34)
                            .background(Color.black)
                            .cornerRadius(40)
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }
}
#Preview {
    PromptQuestionView(
        viewModel: PromptViewModel(
            sectionTitle: "Stay with what you see",
            sectionSubtitle: "You don't need to capture everything.\none thing is enough.",
            prompts: [
                SensePrompt(question: "What sound belongs to this place?", sense: .sight),
                SensePrompt(question: "What detail would disappear if you blinked?", sense: .sight)
            ]
        )
    )
}
