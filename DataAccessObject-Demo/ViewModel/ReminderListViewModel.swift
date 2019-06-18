//
//  ReminderListViewModel.swift
//  DataAccessObject-Demo
//
//  Created by Sasmito Adibowo on 18/6/19.
//  Copyright © 2019 Basil Salad Software. All rights reserved.
//  https://cutecoder.org
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
import Foundation
import ReminderDataModel

class ReminderListViewModel: NSObject {
    var items = [ReminderItemViewModel]()
    var itemCount: Int {
        return items.count
    }
    
    func item(atIndex i: Int) -> ReminderItemViewModel {
        return items[i]
    }
}


extension ReminderListViewModel {
    convenience init(items: [ReminderItem]) {
        self.init()
        self.items = items.map(ReminderItemViewModel.init(reminderItem:))
    }
}
