//
//  ContentView.swift
//  Song Roulette
//
//  Created by Deon Aftahi on 2024-10-26.
//

import SwiftUI

struct ContentView: View {
    @State private var animateOffset: CGFloat = 0 //initial 5 covers
    @State private var albumCovers: [String] = (0..<5).map { "album\($0)" }
    @State private var isNavigating = false
    @State private var timer: Timer?
    
    // Full list of 48 covers
    let allImages = (0..<48).map { "album\($0)" }
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack{
                    Spacer(minLength: 550)
                    //Background scrolling images
                    GeometryReader { geometry in
                        HStack(spacing: 0){
                            ForEach(albumCovers, id: \.self) {imageName in
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width / 2)
                            }
                        }
                        .offset(x: animateOffset - 600)
                        .onAppear{
                            if !isNavigating{
                                startScrolling(geometry: geometry)
                            }
                        }
                        .onDisappear{
                            stopScrolling()
                        }
                    }
                }
                //Main Content
                VStack {
                    
                    Spacer(minLength: 10)
                    
                    //App Name
                    Text("Song Roullette")
                        .font(.custom("Futura", size: 75))
                        .padding(.bottom, 50)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    //Play Button
                    NavigationLink(destination: PlayerSelectView()){
                        Text("Play")
                            .font(.custom("Futura", size: 40))
                            .bold()
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .simultaneousGesture(TapGesture().onEnded{
                        isNavigating.toggle()
                    })
                    
                    Spacer(minLength: 350)
                }
                .padding()
            }
            .toolbar(.hidden)
        }
        .tint(.green)
    }
    
    func stopScrolling(){
        timer?.invalidate()
        timer = nil
    }
    
    func startScrolling(geometry: GeometryProxy){
        //Each cycle duration
        let duration = 2.0
        let imageWidth = geometry.size.width / 2 //width of one cover
        
        withAnimation(Animation.linear(duration: duration)){
            animateOffset = imageWidth
        }
        
        //Timer
        Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { _ in
            animateOffset = 0
            updateAlbumCovers()
            withAnimation(Animation.linear(duration: duration)){
                animateOffset = imageWidth
            }
        }
    }
    
    func updateAlbumCovers(){
        if let newCover = allImages.randomElement(){
            if !albumCovers.contains(newCover){
                albumCovers.removeLast()
                albumCovers.insert(newCover, at: 0)
            }else{
                updateAlbumCovers()
            }
        }
    }
}

struct PlayerSelectView: View{
    @State private var selectedPlayerCount: Int = 3 //Default player count
    
    var body: some View{
        VStack{
            Spacer(minLength: 10)
            
            //App Name
            Text("Select Number Of Players")
                .font(.custom("Futura", size: 45))
                .padding(.bottom, 50)
                .bold()
                .multilineTextAlignment(.center)
            
            
            
            Picker("Number of Players", selection: $selectedPlayerCount){
                ForEach(3..<10){ number in
                    Text("\(number)")
                        .font(.custom("Futura", size: 40))
                        .foregroundStyle(.black)
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 175, height: 200)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
            
            Spacer()
            
            NavigationLink(destination: SongSelectView(selectedPlayerCount: selectedPlayerCount)){
                Text("Start")
                    .font(.custom("Futura", size: 40))
                    .bold()
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Spacer()
        }
    }
}
struct SongSelectView: View{
    
    let selectedPlayerCount: Int
    @State private var selectedSongs: [Bool]
    @State private var showingSongPicker: Bool = false
    @State private var currentPlayerIndex: Int?
    
    init(selectedPlayerCount: Int) {
        self.selectedPlayerCount = selectedPlayerCount
        _selectedSongs = State(initialValue: Array(repeating: false, count: selectedPlayerCount ))
    }
    
    var body: some View{
        VStack{
            Text("Select your Songs")
                .font(.custom("Futura", size: 40))
                .bold()
                .padding(.bottom, 50)
            
            ForEach (0..<selectedPlayerCount, id : \.self) { index in
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.green, lineWidth: 3)
                                        .fill(selectedSongs[index] ? Color.green : Color.black)
                                        .frame(height: 60)
                                        .padding(.horizontal, 30)
                                        .padding(.bottom, 10)
                    //Lock icon if selected
                    if selectedSongs[index] {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 40)
                            .foregroundStyle(.black)
                    }
                }
                .onTapGesture {
                    currentPlayerIndex = index
                    showingSongPicker = true
                }
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingSongPicker) {
            SongPickerView(playerIndex: currentPlayerIndex, onSongSelected: {selectedSong in if let index = currentPlayerIndex {
                selectedSongs[index] = true
            }})
        }
    }
}

struct SongPickerView: View{
    var playerIndex: Int?
    var onSongSelected: (String) -> Void
    
    @State private var searchText: String = ""
    @State private var searchResults: [String] = []
    
    var body: some View{
        NavigationView{
            VStack{
                TextField("Search for a song...", text: $searchText, onCommit: searchSongs)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                List(searchResults, id: \.self) { song in
                    Button(action: {
                        onSongSelected(song)
                    }){
                        Text(song)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Pick a Song")
        }
    }
    
    func searchSongs(){
        searchResults = [
            
        ]
    }
}

#Preview {
    ContentView()
}
