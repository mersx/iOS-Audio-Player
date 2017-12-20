//  Created by Alexander Martynov on 11/11/17.
//  All sample songs was downloaded for free from purevolume.com. These songs are belong to their authors.

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

class PlayerVC: UIViewController {
    
    var updater: CADisplayLink! = nil
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playingTimeLabel: UILabel!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setUpdater()
        
        print(currentSong)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultSong()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updater.invalidate()
    }
    
    //MARK: - Methods
    
    func defaultSong() {
        if musicIsPlaying == false {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: songList[currentSong].url!)
            } catch {
                print("Eror!")
            }
        }
    }
    
    func setUpdater() {
        updater = CADisplayLink(target: self, selector: #selector(updatingProgressItems))
        updater.preferredFramesPerSecond = 2
        updater.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    @objc func updatingProgressItems() {
        songNameLabel.text = songList[currentSong].fullTrackName

        audioPlayer.delegate = self
        
        albumCover.image = songList[currentSong].artwork
        
        progressSlider.setValue(Float(audioPlayer.currentTime), animated: true)
        progressSlider.maximumValue = Float(audioPlayer.duration)
        
        
        // making normal time format of song
        let currentTimePlaying = Int(audioPlayer.currentTime)
        let minutesPlaying = currentTimePlaying / 60
        let secondsPlaying = currentTimePlaying - minutesPlaying * 60
        playingTimeLabel.text = NSString(format: "%02d:%02d", minutesPlaying, secondsPlaying) as String
        
        let currentTimeDuration = Int(audioPlayer.duration)
        let minutesDuration = currentTimeDuration / 60
        let secondsDuration = currentTimeDuration - minutesDuration * 60
        durationTimeLabel.text = NSString(format: "%02d:%02d", minutesDuration, secondsDuration) as String
        
        if audioPlayer.isPlaying {
            playButton.setImage(#imageLiteral(resourceName: "pause-btn"), for: .normal)
        } else {
            playButton.setImage(#imageLiteral(resourceName: "play-btn"), for: .normal)
        }
    }
    
    //TODO: - Deal with background music
    func backgroundMusic() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {}
    }
    func setupRemoteTransportControls() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(playControlCenter))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(pauseControlCenter))
    }
    @objc func playControlCenter() {
        audioPlayer.play()
    }
    @objc func pauseControlCenter() {
        audioPlayer.pause()
    }
    
    func playCurrentSong() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: songListChangeable[currentSong].url!)
            musicIsPlaying = true
            audioPlayer.play()
        } catch {
            print("Eror!")
        }
    }
    
    func doPrevSong() {
        audioPlayer.stop()
        musicIsPlaying = false
        
        currentSong -= 1
        
        if currentSong < 0 {
            currentSong = songList.count - 1
        }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: songList[currentSong].url!)
        } catch {
            print("Can't set the previus song")
        }
    }
    
    func doNextSong() {
        audioPlayer.stop()
        musicIsPlaying = false
        
        currentSong += 1
        
        if currentSong >= songList.count {
            currentSong = 0
        }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: songList[currentSong].url!)
        } catch {
            print("Can't set the next song")
        }
    }
    
    //MARK: - Actions
    
    @IBAction func playButton(_ sender: UIButton) {
        if audioPlayer.isPlaying {
            musicIsPlaying = false
            audioPlayer.pause()
        } else {
            musicIsPlaying = true
            audioPlayer.play()
        }
    }
    
    @IBAction func prevSong(_ sender: UIButton) {
        doPrevSong()
    }
    
    @IBAction func nextSong(_ sender: UIButton) {
        doNextSong()
    }
    
    // action which rewinds track
    @IBAction func setTimeIntervalProgressSlider (_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(progressSlider.value)
    }
}


//MARK: - Extensions
extension PlayerVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            doNextSong()
            musicIsPlaying = true
            audioPlayer.play()
        }
    }
}
