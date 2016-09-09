//
//  FeedDetailsViewController.swift
//  AIO-iOS
//
//  Created by Paula Petcu on 9/6/16.
//  Copyright © 2016 monohelix. All rights reserved.
//

import UIKit
import Charts

class FeedDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedFeed: String!
    var limit: String!
    
    var tableView:UITableView?
    var histItems = NSMutableArray()
    
    let dayTimePeriodFormatter = NSDateFormatter()
    
    @IBOutlet var lineChartView: LineChartView!
    
    @IBOutlet var feedDetailsView: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.title = selectedFeed
        
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY HH:mm:ss"
    }

    
    override func viewWillAppear(animated: Bool) {
        
        limit = "50" // default value
        refreshHistFeedData()
        
        updateTableView(UIScreen.mainScreen().bounds.height, w: UIScreen.mainScreen().bounds.width)
        
    }
    
    
    func refreshHistFeedData() {
        self.histItems.removeAllObjects();
        RestApiManager.sharedInstance.getHistoricalData(selectedFeed, limit: limit) { (json: JSON) in
            let history: JSON = json
            for (_, subJson) in history {
                if let hist: AnyObject = subJson.object {
                    self.histItems.addObject(hist)
                    self.histItems.sortUsingDescriptors([NSSortDescriptor(key: "created_epoch", ascending: false)])
                    if (self.histItems.count != 0) {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.tableView?.reloadData()
                        })
                    }
                    
                }
            }
            self.updateChart()
        }
    }
    
    func updateChart() {
        
        var sortedHistItems = self.histItems.mutableCopy() as! NSMutableArray
        sortedHistItems.sortUsingDescriptors([NSSortDescriptor(key: "created_epoch", ascending: true)])
        
        var xs = [Double]()
        var ys = [Double]()
        var yse = [ChartDataEntry]()
        for histItem in sortedHistItems {
            xs.append(histItem["created_epoch"] as! Double)
            let x = histItem["created_epoch"] as! Double
            ys.append(Double(histItem["value"] as! String)!)
            let y = Double(histItem["value"] as! String)!
            yse.append(ChartDataEntry(x: x,y: y))
        }
        
        let data = LineChartData()
        
        let ds1 = LineChartDataSet(values: yse, label: selectedFeed)
        ds1.colors = [UIColor(red: 81.0/255.0, green: 173.0/255.0, blue: 233.0/255.0, alpha: 1.0)]
        ds1.drawCirclesEnabled = false
        ds1.drawValuesEnabled = false
        ds1.drawFilledEnabled = true
        ds1.fillColor = UIColor(red: 81.0/255.0, green: 173.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        ds1.mode = LineChartDataSet.Mode.CubicBezier
        ds1.cubicIntensity = 0.2
        ds1.setDrawHighlightIndicators(false)
        
        data.addDataSet(ds1)
        
        self.lineChartView.data = data
        self.lineChartView.rightAxis.enabled = false
        self.lineChartView.legend.enabled = false
        self.lineChartView.extraLeftOffset = 10
        self.lineChartView.extraBottomOffset = 10
        self.lineChartView.extraRightOffset = 10
        self.lineChartView.leftAxis.drawGridLinesEnabled = false
        self.lineChartView.leftAxis.axisMaximum = ys.maxElement()! + 10/100*(ys.maxElement()!-ys.minElement()!)
        self.lineChartView.leftAxis.axisMinimum = ys.minElement()! - 10/100*(ys.maxElement()!-ys.minElement()!)
        self.lineChartView.xAxis.labelPosition = Charts.XAxis.LabelPosition.Bottom
        self.lineChartView.xAxis.setLabelCount(5, force: true)
        self.lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        self.lineChartView.xAxis.drawAxisLineEnabled = false
        let granularity = decideTimeGranularityBasedOnData(xs)
        self.lineChartView.xAxis.valueFormatter = DateValueFormatter(granularity: granularity)
        
        self.lineChartView.gridBackgroundColor = NSUIColor.whiteColor()
        self.lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
        self.lineChartView.descriptionText = ""
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        updateTableView(size.height,w: size.width)
    }
    
    func updateTableView(h: CGFloat, w: CGFloat) {
        
        if tableView != nil {
            self.tableView?.removeFromSuperview()
        }
        
        // Only show the table if in Portrait
        if(!UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            
            let frame:CGRect = CGRect(x: 0, y: 280, width: w, height: h-380)
            self.tableView = UITableView(frame: frame)
            self.tableView?.dataSource = self
            self.tableView?.delegate = self
            self.view.addSubview(self.tableView!)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.histItems.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") //as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        cell!.userInteractionEnabled = false
        
        let histItem:JSON =  JSON(self.histItems[indexPath.row])
        
        if let timestamp: AnyObject = histItem["created_epoch"].double {
            //cell!.textLabel?.text = timestamp as? String
            
            cell!.textLabel?.text = dayTimePeriodFormatter.stringFromDate(NSDate(timeIntervalSince1970: (timestamp as? Double)!))
            
            if let val: AnyObject = histItem["value"].string {
                cell!.textLabel?.text = (cell!.textLabel?.text)! + "\t\t" + (val as! String)
                cell!.textLabel!.enabled = true
            }
            
            cell!.textLabel?.font = UIFont(name: "Arial",size:14.0)
        }
        return cell!
    }

    @IBAction func onGranularityChange(sender: UISegmentedControl) {
        
        let selectedSegment = sender.selectedSegmentIndex
        
        switch selectedSegment {
        case 0:
            limit = "50"
        case 1:
            limit = "100"
        case 2:
            limit = "200"
        case 3:
            limit = "500"
        default:
            limit = "50"
        }
        
        refreshHistFeedData()
    }
    
    func decideTimeGranularityBasedOnData(xs: [Double]) -> String {
        
        let cal = NSCalendar.currentCalendar()
        let dayCalendarUnit: NSCalendarUnit = [.Day]
        let dayDifference = cal.components(
            dayCalendarUnit,
            fromDate: NSDate(timeIntervalSince1970: (xs.minElement())!),
            toDate: NSDate(timeIntervalSince1970: (xs.maxElement())!),
            options: [])
        
        if (dayDifference.day < 1) {
            return "time"
        }
        else {
            return "datetime"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editFeed" {
            
            // get a reference to the second view controller
            let editFeedViewController = segue.destinationViewController as! EditFeedViewController
            
            // set a variable in the second view controller with the data to pass
            editFeedViewController.selectedFeed = selectedFeed
        }
    }

}
