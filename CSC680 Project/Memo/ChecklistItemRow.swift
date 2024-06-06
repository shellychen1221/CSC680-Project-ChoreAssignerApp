import SwiftUI
struct ChecklistItemRow: View {
    @Binding var checklistItem: ChecklistItem
    
    var body: some View {
        HStack {
            
            TextField("Checklist Item", text: $checklistItem.title)
            
            Spacer()
            Image(systemName: checklistItem.isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(checklistItem.isChecked ? .green : .gray)
                .onTapGesture {
                    checklistItem.isChecked.toggle()
                }
        }
    }
}
