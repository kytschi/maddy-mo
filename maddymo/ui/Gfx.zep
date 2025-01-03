/**
 * Maddy Mo Gfx
 *
 * @package     MaddyMo\Ui\Gfx
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
namespace MaddyMo\Ui;

use MaddyMo\Controllers\Controller;

class Gfx extends Controller
{
    public function buttonAdd(string url, string title)
    {
        return "<a href='" . url . "' class='button' title='" . title . "'>
            <svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='currentColor' viewBox='0 0 16 16'>
                <path d='M8 6.5a.5.5 0 0 1 .5.5v1.5H10a.5.5 0 0 1 0 1H8.5V11a.5.5 0 0 1-1 0V9.5H6a.5.5 0 0 1 0-1h1.5V7a.5.5 0 0 1 .5-.5'/>
                <path d='M14 4.5V14a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V2a2 2 0 0 1 2-2h5.5zm-3 0A1.5 1.5 0 0 1 9.5 3V1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V4.5z'/>
            </svg>
            <label>Add</label>
        </a>";
    }

    public function buttonBack(string url, string title)
    {
        return "<a href='" . url . "' class='button' title='" . title . "'>
            <svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='currentColor' viewBox='0 0 16 16'>
                <path fill-rule='evenodd' d='M1 8a7 7 0 1 0 14 0A7 7 0 0 0 1 8m15 0A8 8 0 1 1 0 8a8 8 0 0 1 16 0m-4.5-.5a.5.5 0 0 1 0 1H5.707l2.147 2.146a.5.5 0 0 1-.708.708l-3-3a.5.5 0 0 1 0-.708l3-3a.5.5 0 1 1 .708.708L5.707 7.5z'/>
            </svg>
            <label>Back</label>
        </a>";
    }

    public function buttonDelete(string url, string title)
    {
        return "<a href='" . url . "' class='button' title='" . title . "'>
            <svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='currentColor' viewBox='0 0 16 16'>
                <path d='M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5m2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5m3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0z'/>
                <path d='M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4zM2.5 3h11V2h-11z'/>
            </svg>
            <label>Login</label>
        </a>";
    }

    public function buttonEdit(string url, string title)
    {
        return "<a href='" . url . "' class='button' title='" . title . "'>
            <svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='currentColor' viewBox='0 0 16 16'>
                <path d='M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z'/>
                <path fill-rule='evenodd' d='M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5z'/>
            </svg>
        </a>";
    }

    public function buttonLogin()
    {
        return "<button type='submit' name='login' title='Click to login'>
            <svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
                <path fill-rule='evenodd' d='M6 3.5a.5.5 0 0 1 .5-.5h8a.5.5 0 0 1 .5.5v9a.5.5 0 0 1-.5.5h-8a.5.5 0 0 1-.5-.5v-2a.5.5 0 0 0-1 0v2A1.5 1.5 0 0 0 6.5 14h8a1.5 1.5 0 0 0 1.5-1.5v-9A1.5 1.5 0 0 0 14.5 2h-8A1.5 1.5 0 0 0 5 3.5v2a.5.5 0 0 0 1 0z'/>
                <path fill-rule='evenodd' d='M11.854 8.354a.5.5 0 0 0 0-.708l-3-3a.5.5 0 1 0-.708.708L10.293 7.5H1.5a.5.5 0 0 0 0 1h8.793l-2.147 2.146a.5.5 0 0 0 .708.708z'/>
            </svg>
            <label>Login</label>
        </button>";
    }

    private function generic(string type = "text", string label, string name, string placeholder = "", string value = "", bool required = false)
    {
        return "<div class='input-group'>
            <label>" . label . (required ? "<span class='required'>*</span>" : "" ). "</label>
            <input type='" . type . "' name='" . name . "' value='" . value . "'" . (required ? " required='required'" : "") . (placeholder ? " placeholder='" . placeholder . "'" : "") . ">
        </div>";
    }

    public function password(string label, string name, string placeholder = "", string value = "", bool required = false)
    {
        return this->generic("password", label, name, placeholder, value, required);
    }

    public function searchBox(string url)
    {
        var html = "";

        let html = "<form action='" . url . "' method='post' id='search-box'>
            <div class='col-auto'>Search</div>
            <div class='col'><div class='input-group'><input name='q' type='text' value='" . (isset(_POST["q"]) ? _POST["q"]  : ""). "'></div></div>
            <div class='col-auto'>
                <button type='submit' name='search' value='search' class='float-right'>search</button>";
                if (isset(_POST["q"])) {
                    let html .= "<a href='" . url . "' class='float-right button'>clear</a>";
                }
        let html .= "</div></form>";

        return html;
    }

    public function text(string label, string name, string placeholder = "", string value = "", bool required = false)
    {
        return this->generic("text", label, name, placeholder, value, required);
    }
}