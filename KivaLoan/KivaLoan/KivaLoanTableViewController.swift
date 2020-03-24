
import UIKit

class KivaLoanTableViewController: UITableViewController {
    
    private let kivaLoanURL = "https://api.kivaws.org/v1/loans/newest.json"
    private var loans = [Loan]()
    
    private func getLatestLoans() {
        guard let loanURL = URL(string: kivaLoanURL) else {
            return
        }
        
        let request = URLRequest(url: loanURL)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // handle error here
            if let error = error {
                print(error)
                return
            }
            
            // Parse response here
            if let data = data {
                self.loans = self.parseLoanData(data: data)
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }

    private func parseLoanData(data: Data) -> [Loan] {
        var loans = [Loan]()
        let decoder = JSONDecoder()
        
        do {
            let loanDataStore = try decoder.decode(LoansDataStore.self, from: data)
            loans = loanDataStore.loans
        } catch {
            print(error)
        }
        
        return loans
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 92.0
        tableView.rowHeight = UITableView.automaticDimension
        
        // Make API call
        getLatestLoans()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! KivaLoanTableViewCell

        cell.nameLabel.text = loans[indexPath.row].name
        cell.countryLabel.text = loans[indexPath.row].country
        cell.useLabel.text = loans[indexPath.row].use
        cell.amountLabel.text = "$\(loans[indexPath.row].amount)"

        return cell
    }

}
