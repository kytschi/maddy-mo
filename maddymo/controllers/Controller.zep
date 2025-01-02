/**
 * Maddy Mo controller
 *
 * @package     MaddyMo\Controllers\Controller
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

use MaddyMo\Exceptions\Exception;
use MaddyMo\Ui\Head;

class Controller
{
    public db;
    public global_url = "/";
    public routes = [];
    public settings;

    public per_page = 100;

    public function __construct(settings = null, db = null)
    {
        let this->settings = settings;
        let this->db = db;
    }

    public function cleanUrl(string path, string clean)
    {
        return str_replace(
            "/" . (this->settings ? this->settings->url_key : "") . clean,
            "",
            path
        );
    }

    public function error(string message = "Missing required fields")
    {
        return "<div class='error box wfull'>
        <div class='box-title'>
            <span>Error</span>
        </div>
        <div class='box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function getPageId(string path)
    {
        var splits;

        let splits = explode("/", path);
        return array_pop(splits);
    }

    public function info(string message)
    {
        return "<div class='info box wfull'>
            <div class='box-title'>
                <span>Info</span>
            </div>
            <div class='box-body'>
                <p>" . message . "</p>
            </div></div>";
    }

    public function header(title)
    {
        return "<div id='header' class='row w-100'>
            <div class='col'>" . title . "</div>
        </div>";
    }

    public function pagination(int count, int page, string url)
    {
        var html, pages = 1, start = 1, end = 10;

        let pages = intval(count / this->per_page);
        if (pages < 1) {
            let pages = 1;
        }
        if ((pages * this->per_page) < count) {
            let pages += 1;
        }
        if (page >= end) {
            let start = intval(page / 10) * 10;
        }

        let end = start + 9;
        if (end > pages) {
            let end = pages;
        }

        let html = "
        <div class='pagination w-100'>
            <span>" . count  . " result(s)</span><div>";

        let html .= "<a href='" . this->urlAddKey(url) . "?page=1'>&lt;&lt;</a>";
        let html .= "<a href='" . this->urlAddKey(url) . "?page=" . (page == 1 ? 1 : page - 1). "'>&lt;</a>";

        while(start <= end) {
            let html .= "<a href='" . this->urlAddKey(url) . "?page=" . start . "'";
            if (start == page) {
                let html .= " class='selected'";
            }
            let html .= ">" . start . "</a>";
            let start += 1;
        }

        let html .= "<a href='" . this->urlAddKey(url) . "?page=" . (page == pages ? pages : page + 1). "'>&gt;</a>";
        let html .= "<a href='" . this->urlAddKey(url) . "?page=" . pages . "'>&gt;&gt;</a>";

        let html .= "</div></div>";

        return html;
    }

    public function redirect(string url)
    {
        header("Location: " . url);
        die();
    }

    public function router(string path, database, settings)
    {
        var route, func;

        let this->db = database;
        let this->settings = settings;
        let this->global_url = this->urlAddKey(this->global_url);

        for route, func in this->routes {
            if (strpos(path, this->urlAddKey(route)) !== false) {
                return this->{func}(path);
            }
        }

        return "";
    }

    public function saveFailed(string message)
    {
        return "<div class='box error'>
        <div class='box-title'>
            <span>save error</span>
        </div>
        <div class='box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function saveSuccess(string message)
    {
        return "<div class='box success'>
        <div class='box-title'>
            <span>save all done</span>
        </div>
        <div class='box-body'>
            <p>" . message . "</p>
        </div></div>";
    }

    public function urlAddKey(string path)
    {
        return "/" . (this->settings ? this->settings->url_key : "") . path;
    }

    public function urlDecode(string value)
    {
        return urldecode(str_replace("%2E", ".", value));
    }

    public function urlEncode(string value)
    {
        return str_replace(".", "%2E", urlencode(value));
    }

    public function validate(array data, array checks)
    {
        var iLoop = 0;
        while (iLoop < count(checks)) {
            if (!isset(data[checks[iLoop]])) {
                return false;
            }
            
            if (empty(data[checks[iLoop]])) {
                return false;
            }
            let iLoop = iLoop + 1;
        }
        return true;
    }

    public function writeMigrations()
    {
        file_put_contents(
            rtrim(this->settings->cron_folder, "/") . "/migrations/migrations.sh",
        "#!/bin/bash
# DO NOT EDIT, AUTOMATICALLY CREATED BY MADDY MO

php -r \"use MaddyMo\\MaddyMo; new MaddyMo('" . this->settings->db_file . "', '" . this->settings->url_key_file . "', false, true);\";"
        );
    }
}