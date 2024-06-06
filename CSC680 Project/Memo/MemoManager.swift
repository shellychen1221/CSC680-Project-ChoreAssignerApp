import SwiftUI

class MemoManager: ObservableObject {
    @Published var memos: [Memo] = []

    init() {
        self.memos = [
            Memo(title: "Shopping List", content: "Buy groceries", date: Date(), checklistItems: [
                ChecklistItem(title: "Milk", isChecked: false),
                ChecklistItem(title: "Eggs", isChecked: true),
                ChecklistItem(title: "Bread", isChecked: false)
            ]),
            Memo(title: "Meeting Notes", content: "Discuss project timeline", date: Date(), checklistItems: [
                ChecklistItem(title: "Agenda 1", isChecked: true),
                ChecklistItem(title: "Agenda 2", isChecked: false),
                ChecklistItem(title: "Agenda 3", isChecked: false)
            ])
        ]
    }

    func addMemo(memo: Memo) {
        memos.append(memo)
    }

    func deleteMemo(at indexSet: IndexSet) {
        memos.remove(atOffsets: indexSet)
    }

    func updateMemo(at index: Int, with memo: Memo) {
        memos[index] = memo
    }

    func filterMemos(by filter: MemoFilter) -> [Memo] {
        switch filter {
        case .memo:
            return memos
        case .checklist:
            return memos.filter { !$0.checklistItems.isEmpty }
        }
    }

    func allChecklistItems() -> [ChecklistItem] {
        memos.flatMap { $0.checklistItems }
    }

    func indexOfChecklistItem(_ checklistItem: ChecklistItem) -> (Int, Int)? {
        for (memoIndex, memo) in memos.enumerated() {
            if let itemIndex = memo.checklistItems.firstIndex(of: checklistItem){
                return (memoIndex, itemIndex)
            }
        }
        return nil
    }
}

enum MemoFilter {
    case memo
    case checklist
}
