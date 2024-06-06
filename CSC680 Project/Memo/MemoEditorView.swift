import SwiftUI
struct MemoEditorView: View {
    @ObservedObject var memoManager: MemoManager
    @Binding var isPresented: Bool
    var memo: Memo?
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var date: Date = Date()
    @State private var checklistItems: [ChecklistItem] = []
    @State private var isSaving: Bool = false
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Content", text: $content)
            DatePicker("Date", selection: $date, displayedComponents: .date)
            
            Section(header: Text("Checklist")) {
                ForEach(checklistItems.indices, id: \.self) { index in
                    if !checklistItems[index].isChecked {
                        ChecklistItemRow(checklistItem: self.$checklistItems[index])
                    }
                }
                Button(action: {
                    self.checklistItems.append(ChecklistItem(title: "", isChecked: false))
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                }
            }


            
            Button(action: {
                isSaving = true
                saveMemo()
            }) {
                Text("Save")
            }
            .disabled(isSaving)
        }
        .onAppear {
            if let memo = memo {
                title = memo.title
                content = memo.content
                date = memo.date
                checklistItems = memo.checklistItems
            }
        }
        .navigationBarTitle(memo != nil ? "Edit Memo" : "Add Memo")
    }

    private func saveMemo() {
        let updatedMemo = Memo(title: title, content: content, date: date, checklistItems: checklistItems)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let memo = memo {
                if let index = memoManager.memos.firstIndex(of: memo) {
                    memoManager.updateMemo(at: index, with: updatedMemo)
                }
            } else {
                memoManager.addMemo(memo: updatedMemo)
            }
            isSaving = false
            isPresented = false
        }
    }
}
