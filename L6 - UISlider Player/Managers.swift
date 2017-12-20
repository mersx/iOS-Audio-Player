import UIKit
import AVFoundation

var audioPlayer = AVAudioPlayer()

var songList: [Song] = []
var songListChangeable: [Song] = []
var songNames: [String] = []    // works with SearchBar
var currentSongNames: [String] = []    // playlistTable uses this array to display data

var currentSong: Int = 0
var musicIsPlaying: Bool = false
