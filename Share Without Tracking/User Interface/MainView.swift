import SwiftUI
import Rules

struct MainView: View {

    @State
    private var editedRule: ParameterRemovalRule?

    @State
    private var text: String = ""

    var body: some View {
        NavigationView {
            RulesListingScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
