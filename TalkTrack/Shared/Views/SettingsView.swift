//
//  SettingsView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/6/24.
//

import SwiftUI
import SwiftData
import SwiftOpenAI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showAlert = false

    var body: some View {
        VStack {
            Text("Settings")
                .font(.headline)
            Spacer()
            Button(action: {
                showAlert = true
            }) {
                Text("Delete all workout data")
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("This will permanently delete all workout data."),
                    primaryButton: .destructive(Text("Yes"), action: {
                        deleteData()
                    }),
                    secondaryButton: .cancel()
                )
            }
            Spacer()
        }
    }
    
    
    func deleteData() {
        do {
            try modelContext.delete(model: Routine.self)
            print("Deleted all routine data.")
        } catch {
            print("Failed to clear all routine data.")
        }
    }

}

#Preview {
    SettingsView()
        .modelContainer(DataProvider.shared.previewContainer())
}
