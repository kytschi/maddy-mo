/**
 * Maddy Mo Dashboard controller
 *
 * @package     MaddyMo\Controllers\Dashboard
 * @author 		Mike Welsh
 * @copyright   2025 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2025 Mike Welsh
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
namespace MaddyMo\Controllers;

use MaddyMo\Controllers\Controller;
use MaddyMo\Exceptions\Exception;
use MaddyMo\Ui\Gfx;

class Accounts extends Controller
{
    public global_url = "/accounts";

    private credentials_db = "/credentials.db";
    private maddy_db = null;

    public routes = [
        "/accounts/edit": "edit",
        "/accounts": "index"        
    ];

    public function edit(string path)
    {
        var html = "", data, id, status, gfx;
        let gfx = new Gfx();

        let id = this->urlDecode(this->getPageId(path));
        let data = this->getAccounts();
        let status = false;

        for html in data {
            if (id == html) {
                let status = true;
                break;
            }
        }

        if (status == false) {
            let html = "";
            let html .= this->header("Edit account: " . id) . "<div id='page-body'>";
            let html .= this->error("Account not found") . "</div>";
            return html;
        }

        if (isset(_POST["save"])) {
            if (!this->validate(
                _POST,
                [
                    "config",
                    "executable",
                    "hostname",
                    "primary_domain",
                    "local_domains"
                ]
            )) {
                let html .= this->saveFailed("Missing required fields");
            } else {
                let status = this->db->execute(
                    "UPDATE settings 
                    SET 
                        config=:config,
                        executable=:executable,
                        hostname=:hostname,
                        primary_domain=:primary_domain,
                        local_domains=:local_domains 
                    WHERE ID IS NOT NULL",
                    [
                        "config": _POST["config"],
                        "executable": _POST["executable"],
                        "hostname": _POST["hostname"],
                        "primary_domain": _POST["primary_domain"],
                        "local_domains": _POST["local_domains"]
                    ]
                );

                if (!is_bool(status)) {
                    let html .= this->saveFailed("Failed to update the settings");
                } else {
                    this->redirect(this->global_url . "?saved=true");
                }
            }
        }

        let html .= this->header("Edit account: " . id);

        let html .= "
        <div id='page-body'>
            <form class='row gutters' method='post'>
                <div class='col-full'>
                    <div class='box'>
                        <div class='box-body row'>
                            <div class='col'>" .
                                gfx->buttonBack(this->global_url, "Back to accounts list") .
                            "</div>
                            <div class='col text-right'>" .
                                gfx->buttonDelete(this->global_url . "/delete/" . this->urlEncode(id), "Delete the account") .
                            "</div>
                        </div>
                    </div>
                </div>
                <div class='col-full'>
                    <div class='box'>
                        <div class='box-title'>
                            <span class='col'>Account</span>
                            <span class='col required text-right'>* required fields</span>
                        </div>
                        <div class='box-body'>" .
                            gfx->password("Password", "password") .
                            gfx->password("Re-enter password", "password_check") .
                            "
                        </div>
                        <div class='box-footer'>
                            <button class='btn-success' type='submit' name='password_update'>Save</button>
                        </div>
                    </div>
                </div>
            </form>
        </div>";

        return html;
    }

    private function getAccounts()
    {
        var data;
        let data = explode("\n", shell_exec("sudo " . this->settings->executable . " creds list"));
        array_pop(data);
        return data;
    }

    public function index(string path)
    {
        var html, data = [], gfx;

        let gfx = new Gfx(this->settings, this->db);

        try {
            /*let this->maddy_db = new Database(
                "sqlite:" . this->settings->library . this->credentials_db,
                "",
                ""
            );*/

            let data = this->getAccounts();
            
            let html = this->header("Accounts") . "<div id='page-body'>";
            
            if (count(data)) {
                let html .= "
                    <form action='" . this->global_url . "' method='post' class='box'>
                        <table>
                            <tbody>
                                <tr>
                                    <th>Search<span class='required'>*</span></th>
                                    <td>
                                        <input name='q' type='text' value='" . (isset(_POST["q"]) ? _POST["q"]  : ""). "'>
                                    </td>
                                </tr>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan='2'>
                                        <button type='submit' name='search' value='search' class='float-right'>search</button>";
                if (isset(_POST["q"])) {
                    let html .= "<a href='" . this->global_url . "' class='float-right button'>clear</a>";
                }
                let html .= "</td>
                                </tr>
                            </tfoot>
                        </table>
                    </form>";

                let html .= "
                <div class='box'>
                    <table>
                        <thead>
                            <tr>
                                <th>Account</th>
                                <th class='buttons' width='120px'>
                                    <a href='" . this->global_url . "/add" . "' class='mini icon icon-add' title='Create an account'>&nbsp;</a>
                                </th>
                            </tr>
                        </thead>
                        <tbody>";
                    var item;
                    for item in data {
                        let html .= "<tr>
                            <td>" . item . "</td>
                            <td class='buttons'>".
                                gfx->buttonEdit(this->global_url . "/edit/" . this->urlEncode(item), "Manage the account") .
                                gfx->buttonDelete(this->global_url . "/delete/" . this->urlEncode(item), "Delete the account") .
                            "</td>
                        </tr>";
                    }
                    let html .= "
                        </tbody>
                    </table>
                </div>";
            } else {
                let html .= "<h2><span>No accounts found</span></h2>";
                if (isset(_POST["q"])) {
                    let html .= "<p><a href='" . this->global_url . "' class='button'>clear search</a></p>";
                }
                let html .= "<p><a href='" . this->global_url . "/add" . "' class='round icon icon-add'>&nbsp;</a></p>";
            }
        } catch \Exception, data {
            let html .= this->error(data->getMessage());
        }

        return html . "</div>";
    }
}