//
//  TimerControl.swift
//  EyeGuardian
//
//  Created by zhaokai on 5/22/16.
//  Copyright © 2016 zhaokai. All rights reserved.
//

import Cocoa

class TimerControl: NSObject {
    
    let LAST_TIME_INTERVAL : NSTimeInterval = 1

    private var _work_time_interval : NSTimeInterval = 50 * 60
    private var _rest_time_interval : NSTimeInterval = 5 * 60
    private var work_timer : NSTimer = NSTimer()
    private var rest_timer : NSTimer = NSTimer()
    private var last_time_timer : NSTimer = NSTimer()
    
    private var last_current_time : Double = 0
    private var last_total_time : Double = 0
    
    var work_time_interval: NSTimeInterval {
        get {
            return _work_time_interval
        }
        set {
            _work_time_interval = newValue
            NSUserDefaults.standardUserDefaults().setObject(_work_time_interval, forKey: "work_time_interval")
        }
    }

    var rest_time_interval : NSTimeInterval {
        get {
            return _rest_time_interval
        }
        set {
            _rest_time_interval = newValue
            NSUserDefaults.standardUserDefaults().setObject(_rest_time_interval, forKey: "rest_time_interval")
        }
    }

    func start() {
        NSLog("TimerControl::start()")
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        updateLastTimeProgressAndLabel(appDelegate.lastTimeProgress, lastTimeLabel: appDelegate.lastTimeLabel, isWork: true)
        work_timer = NSTimer.scheduledTimerWithTimeInterval(_work_time_interval, target: self, selector: "restStart", userInfo: nil, repeats: false)
        addToScrollView(appDelegate.logText, text: "\nTimerControl log:\n")
        addToScrollView(appDelegate.logText, text: "\t >> start to work, _work_time_interval=\(_work_time_interval)\n")
    }
    
    func startToRest() {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        updateLastTimeProgressAndLabel(appDelegate.lastRestTimeProgress, lastTimeLabel: appDelegate.lastTimeLabel, isWork: false)
        rest_timer = NSTimer.scheduledTimerWithTimeInterval(_rest_time_interval, target: self, selector: "workStart:", userInfo: nil, repeats: false)
        addToScrollView(appDelegate.logText, text: "\t << start to rest, _rest_time_interval=\(_rest_time_interval)\n\n")
        appDelegate.rest()
    }
    
    func stop() {
        work_timer.invalidate()
        rest_timer.invalidate()
        last_time_timer.invalidate()
    }

    func workStart() {
        NSLog("TimerControl::workStart(timer) start to work")
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        updateLastTimeProgressAndLabel(appDelegate.lastTimeProgress, lastTimeLabel: appDelegate.lastTimeLabel, isWork: true)
        work_timer = NSTimer.scheduledTimerWithTimeInterval(_work_time_interval, target: self, selector: "restStart", userInfo: nil, repeats: false)
        addToScrollView(appDelegate.logText, text: "\t >> start to work, _work_time_interval=\(_work_time_interval)\n")
        appDelegate.work()
    }
    
    func restStart() {
        NSLog("TimerControl::restStart(timer) start to rest")
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        updateLastTimeProgressAndLabel(appDelegate.lastRestTimeProgress, lastTimeLabel: appDelegate.lastTimeLabel, isWork: false)
        rest_timer = NSTimer.scheduledTimerWithTimeInterval(_rest_time_interval, target: self, selector: "workStart:", userInfo: nil, repeats: false)
        addToScrollView(appDelegate.logText, text: "\t << start to rest, _rest_time_interval=\(_rest_time_interval)\n\n")
        appDelegate.rest()
    }
    
    func addToScrollView(sv: NSScrollView, text: String) {
        let textView = sv.documentView as! NSTextView
        textView.string?.appendContentsOf(text)
    }
    
    func updateLastTimeProgressAndLabel(lastTimeProgress : NSProgressIndicator, lastTimeLabel : NSTextField, isWork : Bool) {
        last_current_time = 0
        if (isWork) {
            last_total_time = _work_time_interval
        } else {
            last_total_time = _rest_time_interval
        }
        last_time_timer.invalidate()
        last_time_timer = NSTimer.scheduledTimerWithTimeInterval(LAST_TIME_INTERVAL, target: self, selector: "updateLastTimeProgress:", userInfo: ["lastTimeProgress" : lastTimeProgress, "lastTimeLabel" : lastTimeLabel, "isWork" : isWork], repeats: true)
    }
    
    func updateLastTimeProgress(timer : NSTimer) {
        last_current_time++
        NSLog("\t updateLastTimeProgress: last_current_time=\(last_current_time)  last_total_time=\(last_total_time) doublev=\(last_current_time / last_total_time)")
        let dict = timer.userInfo as! NSDictionary
        let lastTimeProgress = dict["lastTimeProgress"] as! NSProgressIndicator
        let lastTimeLabel = dict["lastTimeLabel"] as! NSTextField
        let isWork = dict["isWork"] as! Bool
        lastTimeProgress.doubleValue = 100 * last_current_time / last_total_time
        var text : String = String(last_total_time - last_current_time) + " seconds until"
        if (isWork) {
            text.appendContentsOf(" rest")
        } else {
            text.appendContentsOf(" work")
        }
        lastTimeLabel.stringValue = text
        lastTimeLabel.sizeToFit()
    }
}
