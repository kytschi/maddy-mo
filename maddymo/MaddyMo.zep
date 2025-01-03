/**
 * Maddy Mo - The email management tool
 *
 * @package     MaddyMo\MaddyMo
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1 alpha
 *
 * Copyright 2024 Mike Welsh
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
*/
namespace MaddyMo;

use MaddyMo\Controllers\Accounts;
use MaddyMo\Controllers\Controller;
use MaddyMo\Controllers\Dashboard;
use MaddyMo\Controllers\Database;
use MaddyMo\Controllers\Settings;
use MaddyMo\Controllers\Users;
use MaddyMo\Exceptions\Exception;
use MaddyMo\Models\Settings as SettingsModel;
use MaddyMo\Ui\Head;

class MaddyMo extends Controller
{
    private logged_in = false;

    public function __construct(string db, string url_key = "", bool commandline = false)
    {
        var splits, username = "", password = "";

        let splits = explode(":", db);

        if (!isset(splits[1])) {
            throw new Exception("Invalid database string", (commandline) ? true : false);
        }

        switch (splits[0]) {
            case "mysql":
                let splits = this->setCredentials(splits[1]);
                let username = splits[0];
                let password = splits[1];
                break;
            case "sqlite":
                if (!file_exists(str_replace("sqlite:", "", db))) {
                    throw new Exception("SQLite DB not found", (commandline) ? true : false);
                }
                break;
            default:
                //Just to stop the compiler warning.
                this->throwError("Invalid database connection", commandline);
                break;
        }

        if (!file_exists(url_key)) {
            throw new Exception("Invalid key", (commandline) ? true : false);
        }

        let this->db = new Database(db, username, password);

        var settings;
        let settings = this->db->get("SELECT * FROM settings LIMIT 1");
        let settings->db_file = db;
        let settings->url_key_file = url_key;
        let settings->url_key = trim(file_get_contents(url_key), "\n");
        let settings->session_key = substr(settings->url_key, 0, 16);
        let this->settings = settings;

        if (strpos(_SERVER["REQUEST_URI"], this->settings->url_key) === false) {
            header("HTTP/1.1 404 Not Found");
            die();
        }

        if (session_status() === 1) {
            session_name(settings->session_key);
            ini_set("session.gc_maxlifetime", 3600);
            ini_set("session.cookie_lifetime", 3600);
            session_start();
        }

        var routes = [
            "/locked": "Users",
            "/accounts": "Accounts",
            "/dashboard": "Dashboard",
            "/settings": "Settings",
            "/users": "Users"
        ];

        var code = 404, path, parsed, output = "", route, func;

        let parsed = parse_url(_SERVER["REQUEST_URI"]);
        let path = "/" . trim(parsed["path"], "/");

        if (path == this->urlAddKey("")) {
            let path = this->urlAddKey("/dashboard");
        }
        
        if (!isset(_SESSION[settings->session_key])) {
            let path = this->urlAddKey("/locked");
            let _SESSION[settings->session_key] = null;
        }

        if (empty(_SESSION[settings->session_key])) {
            let path = this->urlAddKey("/locked");
        } else {
            let this->logged_in = true;
            let code = 200;
        }

        try {
            for route, func in routes {
                if (strpos(path, this->urlAddKey(route)) !== false) {
                    let output = this->{func}(path);
                    break;
                }
            }
        } catch \Exception, route {
            throw new Exception(route->getMessage());
        }
        
        if (empty(output)) {
            let code = 404;
            let output = this->notFound();
        }

        this->head(code);
        echo output;
        this->footer();
    }

    private function accounts(string path)
    {
        var controller;
        let controller = new Accounts();
        return controller->router(path, this->db, this->settings);
    }

    private function dashboard(string path)
    {
        var controller;
        let controller = new Dashboard();
        return controller->router(path, this->db, this->settings);
    }

    private function footer()
    {
        echo "</div></div></body></html>";
    }

    private function head(int code = 200)
    {
        var head;
        let head = new Head(this->settings);

        if (code == 404) {
            header("HTTP/1.1 404 Not Found");
        } elseif (code == 403) {
            header("HTTP/1.1 403 Forbidden");
        }

        echo "<!DOCTYPE html>
            <html lang='en'>" . head->build() . "
                <body>
                    <div class='row w-100'>";
        if (this->logged_in) {
            echo "
                        <div id='side-menu' class='col-auto'>
                            <h1>Maddy Mo</h1>
                            <ul>
                                <li>
                                    <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                                        <path d='M8 4a.5.5 0 0 1 .5.5V6a.5.5 0 0 1-1 0V4.5A.5.5 0 0 1 8 4M3.732 5.732a.5.5 0 0 1 .707 0l.915.914a.5.5 0 1 1-.708.708l-.914-.915a.5.5 0 0 1 0-.707M2 10a.5.5 0 0 1 .5-.5h1.586a.5.5 0 0 1 0 1H2.5A.5.5 0 0 1 2 10m9.5 0a.5.5 0 0 1 .5-.5h1.5a.5.5 0 0 1 0 1H12a.5.5 0 0 1-.5-.5m.754-4.246a.39.39 0 0 0-.527-.02L7.547 9.31a.91.91 0 1 0 1.302 1.258l3.434-4.297a.39.39 0 0 0-.029-.518z'/>
                                        <path fill-rule='evenodd' d='M0 10a8 8 0 1 1 15.547 2.661c-.442 1.253-1.845 1.602-2.932 1.25C11.309 13.488 9.475 13 8 13c-1.474 0-3.31.488-4.615.911-1.087.352-2.49.003-2.932-1.25A8 8 0 0 1 0 10m8-7a7 7 0 0 0-6.603 9.329c.203.575.923.876 1.68.63C4.397 12.533 6.358 12 8 12s3.604.532 4.923.96c.757.245 1.477-.056 1.68-.631A7 7 0 0 0 8 3'/>
                                    </svg>
                                    <a href='" . this->urlAddKey("/") . "'>Dashboard</a>
                                </li>
                                <li>
                                    <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                                        <path d='M2 2a2 2 0 0 0-2 2v8.01A2 2 0 0 0 2 14h5.5a.5.5 0 0 0 0-1H2a1 1 0 0 1-.966-.741l5.64-3.471L8 9.583l7-4.2V8.5a.5.5 0 0 0 1 0V4a2 2 0 0 0-2-2zm3.708 6.208L1 11.105V5.383zM1 4.217V4a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v.217l-7 4.2z'/>
                                        <path d='M14.247 14.269c1.01 0 1.587-.857 1.587-2.025v-.21C15.834 10.43 14.64 9 12.52 9h-.035C10.42 9 9 10.36 9 12.432v.214C9 14.82 10.438 16 12.358 16h.044c.594 0 1.018-.074 1.237-.175v-.73c-.245.11-.673.18-1.18.18h-.044c-1.334 0-2.571-.788-2.571-2.655v-.157c0-1.657 1.058-2.724 2.64-2.724h.04c1.535 0 2.484 1.05 2.484 2.326v.118c0 .975-.324 1.39-.639 1.39-.232 0-.41-.148-.41-.42v-2.19h-.906v.569h-.03c-.084-.298-.368-.63-.954-.63-.778 0-1.259.555-1.259 1.4v.528c0 .892.49 1.434 1.26 1.434.471 0 .896-.227 1.014-.643h.043c.118.42.617.648 1.12.648m-2.453-1.588v-.227c0-.546.227-.791.573-.791.297 0 .572.192.572.708v.367c0 .573-.253.744-.564.744-.354 0-.581-.215-.581-.8Z'/>
                                    </svg>
                                    <a href='" . this->urlAddKey("/accounts") . "'>Accounts</a>
                                </li>
                                <li>
                                    <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                                        <path d='M8 4.754a3.246 3.246 0 1 0 0 6.492 3.246 3.246 0 0 0 0-6.492M5.754 8a2.246 2.246 0 1 1 4.492 0 2.246 2.246 0 0 1-4.492 0'/>
                                        <path d='M9.796 1.343c-.527-1.79-3.065-1.79-3.592 0l-.094.319a.873.873 0 0 1-1.255.52l-.292-.16c-1.64-.892-3.433.902-2.54 2.541l.159.292a.873.873 0 0 1-.52 1.255l-.319.094c-1.79.527-1.79 3.065 0 3.592l.319.094a.873.873 0 0 1 .52 1.255l-.16.292c-.892 1.64.901 3.434 2.541 2.54l.292-.159a.873.873 0 0 1 1.255.52l.094.319c.527 1.79 3.065 1.79 3.592 0l.094-.319a.873.873 0 0 1 1.255-.52l.292.16c1.64.893 3.434-.902 2.54-2.541l-.159-.292a.873.873 0 0 1 .52-1.255l.319-.094c1.79-.527 1.79-3.065 0-3.592l-.319-.094a.873.873 0 0 1-.52-1.255l.16-.292c.893-1.64-.902-3.433-2.541-2.54l-.292.159a.873.873 0 0 1-1.255-.52zm-2.633.283c.246-.835 1.428-.835 1.674 0l.094.319a1.873 1.873 0 0 0 2.693 1.115l.291-.16c.764-.415 1.6.42 1.184 1.185l-.159.292a1.873 1.873 0 0 0 1.116 2.692l.318.094c.835.246.835 1.428 0 1.674l-.319.094a1.873 1.873 0 0 0-1.115 2.693l.16.291c.415.764-.42 1.6-1.185 1.184l-.291-.159a1.873 1.873 0 0 0-2.693 1.116l-.094.318c-.246.835-1.428.835-1.674 0l-.094-.319a1.873 1.873 0 0 0-2.692-1.115l-.292.16c-.764.415-1.6-.42-1.184-1.185l.159-.291A1.873 1.873 0 0 0 1.945 8.93l-.319-.094c-.835-.246-.835-1.428 0-1.674l.319-.094A1.873 1.873 0 0 0 3.06 4.377l-.16-.292c-.415-.764.42-1.6 1.185-1.184l.292.159a1.873 1.873 0 0 0 2.692-1.115z'/>
                                    </svg>
                                    <a href='" . this->urlAddKey("/settings") . "'>Settings</a>
                                </li>
                                <li>
                                    <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                                        <path d='M15 14s1 0 1-1-1-4-5-4-5 3-5 4 1 1 1 1zm-7.978-1L7 12.996c.001-.264.167-1.03.76-1.72C8.312 10.629 9.282 10 11 10c1.717 0 2.687.63 3.24 1.276.593.69.758 1.457.76 1.72l-.008.002-.014.002zM11 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4m3-2a3 3 0 1 1-6 0 3 3 0 0 1 6 0M6.936 9.28a6 6 0 0 0-1.23-.247A7 7 0 0 0 5 9c-4 0-5 3-5 4q0 1 1 1h4.216A2.24 2.24 0 0 1 5 13c0-1.01.377-2.042 1.09-2.904.243-.294.526-.569.846-.816M4.92 10A5.5 5.5 0 0 0 4 13H1c0-.26.164-1.03.76-1.724.545-.636 1.492-1.256 3.16-1.275ZM1.5 5.5a3 3 0 1 1 6 0 3 3 0 0 1-6 0m3-2a2 2 0 1 0 0 4 2 2 0 0 0 0-4'/>
                                    </svg>
                                    <a href='" . this->urlAddKey("/users") . "'>Users</a>
                                </li>
                            </ul>
                        </div>";
        }
        echo "<div" . (this->logged_in ? " id='page'" : "") . " class='col'>";
    }

    private function notFound()
    {
        var html;

        let html = this->header("Page not found");

        let html .= "
        <div id='page-body' class='row'>
            <div class='col'>
                <div class='box'>
                    <div class='box-title'>
                        <span>Error</span>
                    </div>
                    <div class='box-body'>
                        <h1>Page not found</h1>
                    </div>
                    <div class='box-footer'>
                        <button type='button' onclick='window.history.back()'>back</button>
                    </div>
                </div>
            </div>
        </div>";

        return html;
    }

    private function setCredentials(string str)
    {
        var splits, key, username = "", password = "";
        let splits = explode(";", str);
        for key in splits {
            if (strpos(key, "UID=") !== false) {
                let username = str_replace(["UID=", "'", "\""], "", key);
            } elseif (strpos(key, "PWD=") !== false) {
                let password = str_replace(["PWD=", "'", "\""], "", key);
            }
        }

        return [username, password];
    }

    private function settings(string path)
    {
        var controller;
        let controller = new Settings();
        return controller->router(path, this->db, this->settings);
    }

    private function throwError(string message, bool commandline)
    {
        throw new Exception(message, commandline);
    }

    private function users(string path)
    {
        var controller;
        let controller = new Users();
        return controller->router(path, this->db, this->settings);
    }
}