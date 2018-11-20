//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

// The Operation object to execute a scheduled job.
// The object get the hiddenID for the job, reads the
// rsync parameters for the job, creates a object to finalize the
// job after execution as logging. The reference to the finalize object
// is set in the static object. The finalize object is invoked
// when the job discover (observs) the termination of the process.

protocol ReloadData: class {
    func reloaddata(profilename: String?)
}

protocol GetTCPconnections: class {
    func gettcpconnections() -> TCPconnections?
}

class ExecuteTaskTimer: Operation, SetSchedules, SetConfigurations, SetScheduledTask, Setlog {

    override func main() {
        _ = ExecuteTaskDispatch()
    }
}
