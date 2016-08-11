//
//  EffectViewController.swift
//  Effect
//
//  Created by Nicholas Roux on 7/27/16.
//  Copyright © 2016 Nicholas Roux. All rights reserved.
//

import UIKit
import AudioKit
import AVFoundation


class RecordViewController: UIViewController {
    
    @IBOutlet var effectButton: UISwitch!
    @IBOutlet var noiseButton: UISwitch!
    
    var mic: AKMicrophone!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Set the Audio Session of Audiokit to "Play and Record"
        let audioSession = AVAudioSession.sharedInstance()
        do {
            
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        } catch {
        
        }
        
        /// Set universal variable 'mic' as the devices microphone input
        mic = AKMicrophone()
        
            ///---------------------------------------------------------------///
            ///------------------------AUDIOKIT SETTINGS----------------------///
        
            /// .shortest is 32 samples = 0.72 ms @ 44100 Hz
            AKSettings.bufferLength = .Shortest
        
            /// Allows AudioKit to send Notifications
            AKSettings.notificationsEnabled = true
        
            /// Whether to DefaultToSpeaker when audio input is enabled
            AKSettings.defaultToSpeaker = true
        
            /// Whether to allow audio playback to override the mute setting
            AKSettings.playbackWhileMuted = true
        
            /// Whether we should be listening to audio input (microphone)
            AKSettings.audioInputEnabled = true
        
            /// Number of audio channels: 2 for stereo, 1 for mono
            AKSettings.numberOfChannels = 1
        
            /// The sample rate in Hertz
            AKSettings.sampleRate = 44100
        
            ///---------------------------------------------------------------///
        
        /// Mix the mic channels into 1
        let micMixer = AKMixer(mic)
        
        /// Set the audio output to the unfiltered mic input
        AudioKit.output = micMixer
        
        /// Initialize AudioKit
        AudioKit.start()
        
    }
    
    
    
    
    ///---------------------------------------------------------------///
    ///---------------------------Functions--------------------------///
    
    
    
    func soundEffect() {
        /// Mix the mic channels into 1
        let micMixer = AKMixer(mic)
        
        /// Use low-pass filter on mic input
        let lowPassFilter = AKLowPassFilter(micMixer)
        
        /// Low-pass filter settings
        lowPassFilter.cutoffFrequency = 2000 // Hz
        lowPassFilter.resonance = 0 // dB
        
        /// Set the audio output to the low-pass filtered mic input
        AudioKit.output = lowPassFilter
        
        /// Intialize AudioKit
        AudioKit.start()
    }
    
    
    
    func noiseEffect() {
        /// Mix the mic channels into 1
        let micMixer = AKMixer(mic)
        
        /// Use low-pass filter on mic input
        let lowPassFilter = AKLowPassFilter(micMixer)
        
        /// Low-pass filter settings
        lowPassFilter.cutoffFrequency = 2000 // Hz
        lowPassFilter.resonance = 0 // dB
        
        /// Set the audio output to the low-pass filtered mic input
        AudioKit.output = lowPassFilter
        
        /// Intialize AudioKit
        AudioKit.start()
    }
    
    ///---------------------------------------------------------------///
    
    
    
    /// When the effect toggle is engaged by the user
    @IBAction func effect(sender: UISwitch) {
        
        /// Stop AudioKit to apply effects to the microphone input
        AudioKit.stop()
        
        /// Mix the mic channels into 1
        let micMixer = AKMixer(mic)
        
        
        
        /// Check if the effect button is on - the button is turned off by default
        if effectButton!.on {
            
            /// Check if the noise button is also turned on - both should not be on at the same time
            if noiseButton!.on {
                
                    /// Set alert saying that both the effect and noise generation cannot happen simultaneously
                    let alert = UIAlertController(title: "Whoops!",
                                                  message: "You cannot enable the effect with the noise generator activated", preferredStyle: .Alert)
                
                    /// Set the user response to be aware of this condition
                    let action = UIAlertAction(title: "Disable noise generator", style: .Default, handler: nil)
                
                    /// Add the user response button to the alert message
                    alert.addAction(action)
                
                    /// Run the alert message
                    presentViewController(alert, animated: true, completion: {
                        /// Disable the noise generator on alert closure
                        self.noiseButton.setOn(false, animated: true)
                        
                        /// Run the Effect
                        self.soundEffect()
                    })
            
                
            
            /// If the noise button is turned off, proceed with effect
            } else {
                
                /// Run the Effect
                soundEffect()
            
            }
            
        /// Otherwise if the effect button is not turned on
        } else {
            
            /// Set the audio output to the low-pass filtered input
            AudioKit.output = micMixer
            
            /// Initialize AudioKit
            AudioKit.start()
        }
        
    }
    
    
    /// When the noise toggle is engaged by the user
    @IBAction func noise(sender: UISwitch) {
        
        /// Stop AudioKit to apply apply noise based on the db of the microphone input
        AudioKit.stop()
        
        /// Mix the mic channels into 1
        let micMixer = AKMixer(mic)
        
        
        
        /// Check if the noise button is on - the button is turned off by default
        if noiseButton!.on {
            
            /// Check if the effect button is also turned on - both should not be on at the same time
            if effectButton!.on {
                
                /// Set alert saying that both the effect and noise generation cannot happen simultaneously
                let alert = UIAlertController(title: "Whoops!",
                                              message: "You cannot enable the noise generator with the effect activated", preferredStyle: .Alert)
                
                /// Set the user response to be aware of this condition
                let action = UIAlertAction(title: "Disable effect", style: .Default, handler: nil)
                
                /// Add the user response button to the alert message
                alert.addAction(action)
                
                /// Run the alert message
                presentViewController(alert, animated: true, completion: {
                    /// Disable the effect on alert closure
                    self.effectButton.setOn(false, animated: true)
                    
                    /// Run the Effect
                    self.noiseEffect()
                })
                
                
                
            /// If the effect button is turned off, proceed with noise generation
            } else {
                
                /// Run the effect
                noiseEffect()
                
            }
            
        /// Otherwise if the noise button is not turned on
        } else {
            
            /// Set the audio output to the original mic input
            AudioKit.output = micMixer
            
            /// Initialize AudioKit
            AudioKit.start()
        }
        
    }
    
    
   }

