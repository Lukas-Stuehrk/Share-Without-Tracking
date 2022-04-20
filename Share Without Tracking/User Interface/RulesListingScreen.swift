import SwiftUI
import Rules


struct RulesListingScreen: View {

    @State
    private var currentlyEditedRule: RuleEntry? = nil

    @State
    private var rules: [ParameterRemovalRule] = .read()

    var body: some View {
        List {
            ForEach(Array(rules.enumerated()), id: \.element) { index, rule in
                RulePreview(rule: rule)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        currentlyEditedRule = .init(rule: rule, index: index)
                    }
                    .swipeActions {
                        Button(action: {
                            rules.remove(at: index)
                        }) {
                            Image(systemName: "trash.fill")
                            Text("delete")
                        }
                        .tint(.red)
                    }
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    currentlyEditedRule = .init(rule: .empty, index: rules.count)
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $currentlyEditedRule) { entry in
            RuleEditorScreen(
                rule: entry.rule,
                onCancel: { currentlyEditedRule = nil },
                onSave: { newRule in
                    if entry.index >= rules.count {
                        rules.append(newRule)
                    } else {
                        rules[entry.index] = newRule
                    }
                    currentlyEditedRule = nil
                }
            )
        }
        .onChange(of: rules) { ruleSet in
            ruleSet.write()
        }
    }
}


private struct RuleEntry: Identifiable {
    let rule: ParameterRemovalRule
    let index: Int

    var id: Int {
        index
    }
}


private struct RulePreview: View {
    let rule: ParameterRemovalRule

    var body: some View {
        Text("From ") + Text(rule.matchingHost).bold() + Text(" remove ") + Text("\(rule.parametersToBeRemoved.joined(separator: ", "))").bold()
    }
}
