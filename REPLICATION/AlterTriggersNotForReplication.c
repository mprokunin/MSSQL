namespace UpdateTriggerProperty
{
    using Microsoft.SqlServer.Management.Common;
    using Microsoft.SqlServer.Management.Smo;
    using System;
    using System.Threading.Tasks;
    using System.Windows;
    using System.Windows.Threading;

    /// 

    /// Interaction logic for MainWindow.xaml
    /// 

    public partial class MainWindow : Window
    {
        string sqlServerLogin = string.Empty;
        string password = string.Empty;
        string remoteServerName = string.Empty;
        string dbName = string.Empty;
        bool notForReplication = false;

        public MainWindow()
        {
            InitializeComponent();
        }

        private void RunButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                ExtractData();
            }
            catch (Exception ex)
            {
                LogErrorMessage(ex.Message);
            }
        }

        private void ExtractData()
        {
            try
            {
                sqlServerLogin = SqlUserName.Text;
                password = SqlPassword.Password;
                remoteServerName = RemoteServerName.Text;
                dbName = DatabaseName.Text;
                notForReplication = Convert.ToBoolean(NotForReplication.IsChecked);
                Process();
            }
            catch (Exception ex)
            {
                LogErrorMessage(ex.Message);
            }
        }

        private void Process()
        {
            Task.Factory.StartNew(() =>
            {
                try
                {
                    ServerConnection conn = new ServerConnection(remoteServerName)
                    {
                        LoginSecure = false,
                        Login = sqlServerLogin,
                        Password = password,
                    };

                    Server srv = new Server(conn);
                    var db = srv.Databases[dbName];
                    foreach (Table tab in db.Tables)
                    {
                        foreach (Microsoft.SqlServer.Management.Smo.Trigger trig in tab.Triggers)
                        {
                            if (!trig.IsSystemObject)
                            {
                                trig.TextMode = false;
                                trig.NotForReplication = notForReplication;
                                trig.TextMode = true;
                                trig.Alter();

                                OutputBox.Dispatcher.BeginInvoke(DispatcherPriority.Background, new Action(() => OutputBox.Text = trig.Name));
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    LogErrorMessageAsync(ex.Message);
                }
            });
        }

        private void LogErrorMessage(string message)
        {
            OutputBox.Text = string.Empty;
            OutputBox.Text = "An Error Occured\n";
            OutputBox.Text += message;
        }

        private void LogErrorMessageAsync(string message)
        {
            Application.Current.Dispatcher.BeginInvoke(DispatcherPriority.Background, new Action(() =>
            {
                OutputBox.Text = string.Empty;
                OutputBox.Text = "An Error Occured\n";
                OutputBox.Text += message;
            }));
        }
    }
}

