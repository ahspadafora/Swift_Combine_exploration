//: [Previous](@previous)

import SwiftUI
import PlaygroundSupport
import Combine


class MovieViewModel: ObservableObject {
    @Published var searchQuery = ""
    
    @Published private(set) var filteredMovies: [String] = []
    
    private var allMovies: [String] = [
            "The Matrix",
            "The Godfather",
            "The Dark Knight",
            "Inception",
            "Interstellar",
            "Fight Club",
            "Pulp Fiction",
            "Forrest Gump",
            "The Shawshank Redemption",
            "The Social Network",
            "Mad Max: Fury Road"
        ]
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        filteredMovies = allMovies
        
        $searchQuery
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] query in
                guard let self = self else { return [] }
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    return self.allMovies
                }
                return self.allMovies.filter { movie in
                    movie.lowercased().contains(trimmed.lowercased())
                }
            }
            .assign(to: &$filteredMovies)
    }
}

struct MovieView: View {
    @StateObject private var viewModel: MovieViewModel = MovieViewModel()
    
    var body: some View {
        VStack {
            TextField("Search movies...", text: $viewModel.searchQuery)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            if viewModel.filteredMovies.isEmpty {
                Text("No results")
                    .foregroundStyle(.secondary)
            } else {
                List(viewModel.filteredMovies, id: \.self) { movie in
                    Text(movie)
                }
            }
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.setLiveView(
    MovieView()
        .frame(width: 300, height: 300)
)
