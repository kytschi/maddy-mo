/**
 * Maddy Mo Settings controller
 *
 * @package     MaddyMo\Controllers\Settings
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
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
namespace MaddyMo\Controllers;

use MaddyMo\Controllers\Controller;
use MaddyMo\Exceptions\Exception;
use MaddyMo\Ui\Gfx;

class Settings extends Controller
{
    public global_url = "/settings";
    public routes = [
        "/settings": "index"
    ];

    public function index(string path)
    {
        var html = "", data, status, gfx;
        let gfx = new Gfx();

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

        let data = this->db->get("SELECT * FROM settings LIMIT 1");

        let html .= this->header("Settings");

        let html .= "
        <div id='page-body'>
            <form class='row gutters' method='post'>
                <div class='col w-50'>
                    <div class='box'>
                        <div class='box-title'>
                            <span class='col'>Settings</span>
                            <span class='col required text-right'>* required fields</span>
                        </div>
                        <div class='box-body'>" .
                            gfx->text("Config location", "config", data->config, true) .
                            gfx->text("Executable location", "executable", data->executable, true) .
                            gfx->text("Hostname", "hostname", data->hostname, true) .
                            gfx->text("Primary domain", "primary_domain", data->primary_domain, true) .
                            gfx->text("Local domains", "local_domains", data->local_domains, true) .
                            "
                        </div>
                        <div class='box-footer'>
                            <button class='btn-success' type='submit' name='save'>Save</button>
                        </div>
                    </div>
                </div>
            </form>
            <div class='row gutters'>
                <div class='col'>
                    <div class='box'>
                        <div class='box-title'>
                            <span>Maddy config</span>
                        </div>
                        <div class='box-body'>
                            <div class='input-group'>
                                <label>Config</label>
                                <textarea name='config_file' rows='10'>" . 
                                file_get_contents(data->config) .
                                "</textarea>
                            </div>
                        </div>
                        <div class='box-footer'>
                            <button class='btn-success' type='submit' name='save'>Save</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>";

        return html;
    }
}