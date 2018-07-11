import MurrayCore

let tool = Skeleton()

do {
    try tool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
