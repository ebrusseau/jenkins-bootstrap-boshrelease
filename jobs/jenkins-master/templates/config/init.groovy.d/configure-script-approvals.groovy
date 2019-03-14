// This is a stop-gap approach until Jenkins CasC plugin supports script
// approvals - which at the present time is under developement
import org.jenkinsci.plugins.scriptsecurity.scripts.*

jenkinsHome = System.getenv("JENKINS_HOME")
File approvalsFile = new File("${jenkinsHome}/approvedSignatures.txt")

if(approvalsFile.exists() && approvalsFile.canRead()) {
  ScriptApproval scriptApproval = ScriptApproval.get()
  scriptApproval.clearApprovedSignatures()

  approvalsFile.eachLine { line ->

    if (line.trim().size() > 0) {
      println "Approving signature: ${line}"
      scriptApproval.approveSignature(line)
    }
  }

  scriptApproval.save()
}
