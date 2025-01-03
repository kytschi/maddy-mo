/**
 * Maddy Mo database hanlder
 *
 * @package     MaddyMo\Controllers\Database
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

class Database
{
    private db;

    public function __construct(string dsn, string username, string password)
    {
        let this->db = new \PDO(dsn, username, password);
    }

    public function all(string query, array data = [])
    {
        var statement;
        let statement = this->db->prepare(query);
        statement->execute(data);
        return statement->fetchAll(\PDO::FETCH_CLASS, "MaddyMo\\Models\\Model");
    }

    public function execute(string query, array data = [], bool always_save = false)
    {
        var statement, status, errors;

        ob_start();
        let statement = this->db->prepare(query);
        let status = statement->execute(data);
        let errors = ob_get_contents();
        ob_end_clean();

        if (!status) {
            return errors;
        }

        return status;
    }

    public function get(string query, array data = [])
    {
        var statement;
        let statement = this->db->prepare(query);
        statement->execute(data);
        return statement->fetchObject("MaddyMo\\Models\\Model");
    }

    public function uuid() {
        return sprintf(
            "%04x%04x-%04x-%04x-%04x-%04x%04x%04x",
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff ) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0xffff)
        );
    }
}