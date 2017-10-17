//
//  TANSchedulerManager.swift
//  Tango
//
//  Created by Raul Hahn on 1/26/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

private let kMaxNumberOfLocalNotification = 64

class TANSchedulerManager {
    static var sharedInstance: TANSchedulerManager = TANSchedulerManager()
    
    private init() {}
    
    func processSchedulerCampaigns(campaigns: [Campaign]) {
        if campaigns.count > 0 {
            DispatchQueue.global(qos: .userInitiated).async {
                self.schedule(campaigns: campaigns)
            }
        }
    }
    
    private func schedule(campaigns:[Campaign]) {
        for (_, campaign) in campaigns.enumerated() {
            if let campaignScheduler = campaign.scheduler {
                if let startDate = campaignScheduler.startDate?.date() {
                    let endDate = campaignScheduler.endDate?.date() 
                    let schedulerType = SchedulerType.type(campaignScheduler: campaignScheduler)
                    if let toScheduleDates = campaignTriggerDates(campaignScheduler: campaignScheduler) {
                        let scheduler: Scheduler = Scheduler(campaign: campaign, startDateLimit: startDate, endDateLimit: endDate, type: schedulerType, toScheduledDates: toScheduleDates)
                        scheduleIfAvailable(scheduler: scheduler)
                    }
                }
            }
        }
    }

    private func scheduleIfAvailable(scheduler: Scheduler) {
        // TODO: HR merge this in one generic case.
        if #available(iOS 10.0, *) {
            let newNotificationRequests: Set<UNNotificationRequest> = Set.init(TANLocalNotificationComander().notificationRequests(scheduler: scheduler))
            if isCampaignActive(campaign: scheduler.campaign) {
                // TODO: HR remove this when this feature is tested properly and all works.
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                var alreadyScheduledNotifications: Set<UNNotificationRequest> = Set.init()
                let validNewNotificationRequests: Set<UNNotificationRequest> = Set.init(TANLocalNotificationComander().removeExpiredRequests(pendingRequests: Array(newNotificationRequests)))
                var allNotificationRequests: Set<UNNotificationRequest> = validNewNotificationRequests
                UNUserNotificationCenter.current().getPendingNotificationRequests { [unowned self] (notificationRequests) in
                    let validPendingRequests =  TANLocalNotificationComander().removeExpiredRequests(pendingRequests: notificationRequests)
                    alreadyScheduledNotifications = Set.init(TANLocalNotificationComander().tangoNotifications(notifications: validPendingRequests))
                    allNotificationRequests = allNotificationRequests.union(alreadyScheduledNotifications)
                    let allNotificationRequestsSorted: [UNNotificationRequest] = self.ascendingSortNotificationRequest(requests: Array(allNotificationRequests))
                    if allNotificationRequestsSorted.count <= kMaxNumberOfLocalNotification {
                        let notScheduledNotifications = validNewNotificationRequests.subtracting(alreadyScheduledNotifications)
                        self.scheduleNotifications(notificationsRequests: notScheduledNotifications)
                    } else {
                        let allowedNotification = allNotificationRequestsSorted[0...kMaxNumberOfLocalNotification - 1]
                        let firstAllowedRequests: Set<UNNotificationRequest> = Set.init(allowedNotification)
                        let notScheduledNotifications = firstAllowedRequests.subtracting(alreadyScheduledNotifications)
                        self.scheduleNotifications(notificationsRequests: notScheduledNotifications)
                    }
                }
            } else {
                // limits are reached  we should cancel this notifications
                TANLocalNotificationComander().cancelTangoNotifications(notifications: Array(newNotificationRequests))
            }
        } else {
            let scheduledNotification = UIApplication.shared.scheduledLocalNotifications
            let newRequests: [AnyObject] = TANLocalNotificationComander().notificationRequests(scheduler: scheduler)
            if let newRequests = newRequests as? [UILocalNotification] {
                if isCampaignActive(campaign: scheduler.campaign) {
                    // TODO: HR remove this when this feature is tested properly and all works.
                    UIApplication.shared.cancelAllLocalNotifications()
                    let validNewRequests = TANLocalNotificationComander().removeExpiredRequests(pendingRequests: newRequests)
                    let validPendingRequests =  TANLocalNotificationComander().removeExpiredRequests(pendingRequests: scheduledNotification ?? [])
                    let alreadyScheduledTangoNotifications = TANLocalNotificationComander().tangoNotifications(notifications: validPendingRequests)
                    var allNotification = alreadyScheduledTangoNotifications
                    allNotification.append(contentsOf: validNewRequests)
                    let allNotificationSorted = self.ascendingSortNotificationRequest(requests: allNotification)
                    let alreadyScheduledTangoNotificationsSet = Set.init(alreadyScheduledTangoNotifications)
                    if allNotificationSorted.count <= kMaxNumberOfLocalNotification {
                        let newNotificationRequestsSet = Set.init(validNewRequests)
                        let notScheduledNotifications = newNotificationRequestsSet.subtracting(alreadyScheduledTangoNotificationsSet)
                        self.scheduleNotifications(notificationsRequests: notScheduledNotifications)
                    } else {
                        let allowedNotification = allNotificationSorted[0...kMaxNumberOfLocalNotification]
                        let firstAllowedRequests: Set<UILocalNotification> = Set.init(allowedNotification)
                        let notScheduledNotifications = firstAllowedRequests.subtracting(alreadyScheduledTangoNotificationsSet)
                        self.scheduleNotifications(notificationsRequests: notScheduledNotifications)
                    }
                } else {
                    // limits are reached  we should cancel this notifications
                    TANLocalNotificationComander().cancelTangoNotifications(notifications: newRequests)
                }
            }
            
        }
    }
    
    func ascendingSortNotificationRequest<T>(requests: [T]) -> [T] {
        return requests.sorted(by: { (first, second) -> Bool in
            if #available(iOS 10.0, *) {
                if let first = first as? UNNotificationRequest, let second = second as? UNNotificationRequest {
                    var fistDateComponents = (first.trigger as? UNCalendarNotificationTrigger)?.dateComponents ?? Date.distantPast.dateComponents()
                    var secondDateComponents = (second.trigger as? UNCalendarNotificationTrigger)?.dateComponents ?? Date.distantPast.dateComponents()
                    let firstDate = fistDateComponents.currentCalendarDate() ?? Date.distantPast
                    let secondDate = secondDateComponents.currentCalendarDate() ?? Date.distantPast
                    
                    return firstDate.compare(secondDate) == .orderedAscending || firstDate.compare(secondDate) == .orderedSame
                }
            } else if let first = first as? UILocalNotification, let second = second as? UILocalNotification {
                let firstFireDate = first.fireDate ?? Date.distantPast
                let secondFireDate = second.fireDate ?? Date.distantPast
                
                return firstFireDate.compare(secondFireDate) == .orderedAscending || firstFireDate.compare(secondFireDate) == .orderedSame
            }
            
            return true
        })
    }
    
    private func scheduleNotifications<T>(notificationsRequests: Set<T>) {
        TANLocalNotificationComander().addRequests(requests: Array(notificationsRequests) as [AnyObject])
    }
}
