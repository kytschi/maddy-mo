/**
 * Generic exception
 *
 * @package     MaddyMo\Exceptions\Exception
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
namespace MaddyMo\Exceptions;

use MaddyMo\Ui\Head;

class Exception extends \Exception
{
    public code = 500;
    private console = false;
    private back_url = "/";
    
	public function __construct(string message, bool console = false)
	{
        //Trigger the parent construct.
        parent::__construct(message, this->code);

        let this->console = console;
    }

    /**
     * Override the default string to we can have our grumpy cat.
     */
    public function __toString()
    {
        if (this->console) {
            return this->getMessage();
        }
        
        var head;
        let head = new Head();

        if (headers_sent()) {
            return "<p><strong>MADDY MO ERROR</strong><br/>" . this->getMessage() . "</p>";
        }

        if (this->code == 404) {
            header("HTTP/1.1 404 Not Found");
        } elseif (this->code == 400) {
            header("HTTP/1.1 400 Bad Request");
        } else {
            header("HTTP/1.1 500 Internal Server Error");
        }

        return "
        <!DOCTYPE html>
        <html lang='en'>" . head->build() . "
            <body>
                <main>
                    <div id='error' class='box'>
                        <div class='box-title'>
                            <span>Error</span>
                        </div>
                        <div class='box-body'>
                            <p>" . this->getMessage() . "</p>
                        </div>
                        <div class='box-footer'>
                            <a href='" . this->back_url . "' class='button'>back to dashboard</a>
                        </div>
                    </div>
                </main>
            </body>
        </html>";
    }

    /**
     * Fatal error just lets us dumb the error out faster and kill the site
     * so we can't go any futher.
     */
    public function fatal(string url_key = "")
    {
        if (file_exists(url_key)) {
            let this->back_url = "/" . trim(file_get_contents(url_key), "\n");
        }
        echo this;
        die();
    }
}
