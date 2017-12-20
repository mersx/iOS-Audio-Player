//  Created by Alexander Martynov on 11/11/17.
//  All sample songs was downloaded for free from purevolume.com. These songs are belong to their authors.

import UIKit
import AVFoundation

class ListVC: UIViewController {
    
    var updater: CADisplayLink! = nil
    
    // MARK: - Outlets
    
    @IBOutlet weak var playlistTable: UITableView!
    let searchBar = UISearchBar()
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    override func viewWillAppear(_ animated: Bool) {
        setUpdater()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creatingSongList()
        fillingManagersArrays()
        putSearchBarToTop()
        backgroundMusic()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updater.invalidate()
    }
    
    // MARK: - Methods
    
    func creatingSongList() {
        let folderURL = Bundle.main.paths(forResourcesOfType: nil, inDirectory: "Music")
        
        for song in folderURL {
            let songPath = URL(fileURLWithPath: song)
            let avplayerItem = AVPlayerItem(url: songPath)
            let itemOfSongList = Song(withAVPlayerItem: avplayerItem, url: songPath)
            songList.append(itemOfSongList)
        }
        
    }
    
    func backgroundMusic() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {}
    }
    
    func fillingManagersArrays() {
        
        songListChangeable = songList
    }
    
    func putSearchBarToTop() {
        searchBar.placeholder = "Search a song"
        searchBar.delegate = self
        // search bar in navigation bar
        navigationBarItem.titleView = searchBar
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)  // closes keyboard
    }
    
    func setUpdater() {
        updater = CADisplayLink(target: self, selector: #selector(updatingActualCell))
        updater.preferredFramesPerSecond = 1
        updater.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    @objc func updatingActualCell() {
        var index = 0
        var actualIndex: Int?

        for song in songListChangeable {

            print(index)

            if song.fullTrackName == songList[currentSong].fullTrackName {
                actualIndex = index
                break
            } else {
                index += 1
                actualIndex = nil
            }

        }
        
        if actualIndex != nil {
            let selectedIndex = IndexPath(row: actualIndex!, section: 0)

            playlistTable.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        }
    }
    
}

// MARK: - Extensions

extension ListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songListChangeable.count
    }
    
    // what we want display in each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = songListChangeable[indexPath.row].fullTrackName
        cell.textLabel?.textColor = UIColor.white
        
        cell.backgroundColor = UIColor(red: 24.0/255.0, green: 30.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
}

extension ListVC: UITableViewDelegate {
    
    // when user taps on cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: songListChangeable[indexPath.row].url!)
            
            var index = -1
            
            for song in songList {
                index += 1
                if song.fullTrackName == songListChangeable[indexPath.row].fullTrackName {
                    currentSong = index
                    break
                }
            }
            
            musicIsPlaying = true
            audioPlayer.play()
        } catch {
            print("Error!")
        }
    }
}

extension ListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            songListChangeable = songList
            playlistTable.reloadData()
            return
        }
        
        
        songListChangeable = songList.filter({ song -> Bool in
            return song.fullTrackName.lowercased().contains(searchText.lowercased())
        })
        
        playlistTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)  // closes keyboard
    }
}
