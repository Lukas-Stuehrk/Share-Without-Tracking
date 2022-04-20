import SwiftUI
import Rules


private class ViewModel: ObservableObject {

    @Published
    var host: String = ""

    @Published
    var parameters: [String] = [""]

    var isValid: Bool {
        !host.isEmpty && !parameters.filter { !$0.isEmpty }.isEmpty
    }

    func addParameter() {
        parameters.append("")
    }

    func remove(index: Int) {
        parameters.remove(at: index)
        if parameters.isEmpty {
            addParameter()
        }
    }
}



struct RuleEditorScreen: View {

    @ObservedObject
    private var viewModel: ViewModel

    let onCancel: () -> Void

    let onSave: (ParameterRemovalRule) -> Void

    init(rule: ParameterRemovalRule, onCancel: @escaping () -> Void, onSave: @escaping (ParameterRemovalRule) -> Void) {
        let viewModel = ViewModel()
        viewModel.host = rule.matchingHost
        viewModel.parameters = Array(rule.parametersToBeRemoved)
        if viewModel.parameters.isEmpty {
            viewModel.addParameter()
        }
        self.viewModel = viewModel
        self.onCancel = onCancel
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Host", text: $viewModel.host)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }

                Section(header: Text("Remove Parameters")) {
                    Text("All parameters in this list will be removed.")
                        .font(.footnote)


                    ForEach(Array(viewModel.parameters.enumerated()), id: \.offset) { index, element in
                        HStack {
                            TextField("Parameter name", text: $viewModel.parameters[index])
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .textFieldStyle(.roundedBorder)
                            Button(action: { viewModel.remove(index: index) }) {
                                Image(systemName: "trash.circle.fill")
                            }
                        }
                    }

                    Button(action: viewModel.addParameter) {
                        // The plus icon should be infront of the text, that's why we concetanate text instead of using
                        // the function builder of the botton label. Otherwise SwiftUI will break it in two lines where
                        // the first line is the icon and the second line ist the text.
                        Text(Image(systemName: "plus.circle.fill")) + Text(" Add another removal")
                    }
                }
            }
            .navigationBarTitle("Edit Cleanup")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: onCancel) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        onSave(
                            ParameterRemovalRule(
                                host: viewModel.host,
                                parametersToBeRemoved: Set(viewModel.parameters.filter { !$0.isEmpty })
                            )
                        )
                    }) {
                        Image(systemName: "checkmark.circle")
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}
