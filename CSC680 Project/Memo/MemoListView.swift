import SwiftUI
struct MemoListView: View {
    @ObservedObject var memoManager: MemoManager
    @State private var isMemoEditorPresented = false
    @State private var selectedMemo: Memo?
    @State private var filter: MemoFilter = .memo

    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $filter) {
                    Text("Memo").tag(MemoFilter.memo)
                    Text("Checklist").tag(MemoFilter.checklist)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List {
                    if filter == .checklist {
                        ForEach(memoManager.allChecklistItems()) { checklistItem in
                            if !checklistItem.isChecked {
                                if let memoIndex = memoManager.indexOfChecklistItem(checklistItem)?.0,
                                   let itemIndex = memoManager.indexOfChecklistItem(checklistItem)?.1 {
                                    let memo = memoManager.memos[memoIndex]
                                    let item = memo.checklistItems[itemIndex]
                                    ChecklistItemRow(checklistItem: self.$memoManager.memos[memoIndex].checklistItems[itemIndex])
                                }
                            }
                        }
                    } else {
                        ForEach(filteredMemos) { memo in
                            HStack {
                                Text(memo.title)
                                Spacer()
                                Button(action: {
                                    selectedMemo = memo
                                    isMemoEditorPresented = true
                                }) {
                                    Image(systemName: "square.and.pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete(perform: deleteMemo)
                    }
                }
                .navigationBarTitle("Memos")
                .navigationBarItems(trailing: Button(action: {
                    selectedMemo = nil
                    isMemoEditorPresented = true
                }) {
                    Image(systemName: "plus")
                })
                .sheet(isPresented: $isMemoEditorPresented, onDismiss: {
                    selectedMemo = nil
                }) {
                    MemoEditorView(memoManager: memoManager, isPresented: $isMemoEditorPresented, memo: selectedMemo)
                }
            }
        }
    }

    var filteredMemos: [Memo] {
        memoManager.filterMemos(by: filter)
    }

    private func deleteMemo(at indexSet: IndexSet) {
        let memoIndicesToDelete = indexSet.map { memoManager.memos.firstIndex(of: filteredMemos[$0])! }
        for index in memoIndicesToDelete {
            memoManager.deleteMemo(at: IndexSet(integer: index))
        }
    }
}
