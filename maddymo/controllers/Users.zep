/**
 * Maddy Mo users controller
 *
 * @package     DumbDog\Controllers\Users
 * @author 		Mike Welsh
 * @copyright   2024 Mike Welsh
 * @version     0.0.1
 *
 
*/
namespace MaddyMo\Controllers;

use MaddyMo\Controllers\Controller;
use MaddyMo\Exceptions\Exception;
use MaddyMo\Exceptions\NotFoundException;
use MaddyMo\Ui\Gfx;

class Users extends Controller
{
    public global_url = "/users";
    public required = ["username", "nickname"];

    public routes = [
        "/locked": "login",
        "/logout": "logout",
        "/users/add": "add",
        "/users/edit": "edit",
        "/users": "index"
    ];

    public function add(string path)
    {
        var html, model;

        let html = this->header("Add a user") . "<div id='page-body'>";
        
        let model = new \stdClass();
        let model->deleted_at = null;
        let model->deleted_by = null;
        let model->username = "";
        let model->nickname = "";

        if (!empty(_POST)) {
            if (isset(_POST["save"])) {
                var data = [], status = false, err;

                let this->required = array_merge(this->required, ["password", "password_check"]);

                if (!this->validate(_POST, this->required)) {
                    let html .= this->saveFailed("Missing required fields");
                } else {
                    try {
                        if (_POST["password"] != _POST["password_check"]) {
                            throw new \Exception("passwords do not match!");
                        }

                        let data = this->setData(data, model);
                        let data["password"] = password_hash(_POST["password"], PASSWORD_DEFAULT);
                        let data["created_by"] = this->getUserId();
                        let data["id"] = this->db->uuid();
                        
                        let status = this->db->execute(
                            "INSERT INTO users 
                                (
                                    id,
                                    username,
                                    nickname,
                                    `password`,
                                    created_at,
                                    created_by,
                                    updated_at,
                                    updated_by,
                                    status
                                ) 
                            VALUES 
                                (
                                    :id,
                                    :username,
                                    :nickname,
                                    :password,
                                    NOW(),
                                    :created_by,
                                    NOW(),
                                    :updated_by,
                                    'active'
                                )",
                            data
                        );

                        if (!is_bool(status)) {
                            let html .= this->saveFailed("Failed to save the user");
                        } else {
                            let html .= this->saveSuccess("I've saved the user");
                        }
                    } catch \Exception, err {
                        let html .= this->saveFailed(err->getMessage());
                    }
                }
            }
        }

        let html .= this->render(model);

        return html . "</div>";
    }

    public function edit(string path)
    {
        var html, model, data = [];

        let data["id"] = this->getPageId(path);
        let model = this->db->get(
            "SELECT * 
            FROM users 
            WHERE users.id=:id",
            data
        );

        if (empty(model)) {
            throw new NotFoundException("User not found");
        }

        let html = this->header("Edit the user") . "<div id='page-body'>";
        if (model->deleted_at) {
            let html .= this->deletedState("I'm in a deleted state");
        }
        
        if (!empty(_POST)) {
            if (isset(_POST["delete"])) {
                if (!empty(_POST["delete"])) {
                    this->triggerDelete(data["id"]);
                    let html .= this->info("User has been deleted");
                }
            }

            if (isset(_POST["recover"])) {
                if (!empty(_POST["recover"])) {
                    this->triggerRecover(data["id"]);
                    let html .= this->info("User has been recovered");
                }
            }

            if (isset(_POST["save"])) {
                var status = false, query;

                if (!this->validate(_POST, this->required)) {
                    let html .= this->saveFailed("Missing required fields");
                } else {
                    let query = "
                        UPDATE
                            users
                        SET 
                            username=:name,
                            nickname=:nickname,
                            updated_at=NOW(),
                            updated_by=:updated_by";

                    if (isset(_POST["password"]) && isset(_POST["password_check"])) {
                        if (!empty(_POST["password"]) && !empty(_POST["password_check"])) {
                            if (_POST["password"] != _POST["password_check"]) {
                                throw new \Exception("passwords do not match!");
                            }
                            let data["password"] = password_hash(_POST["password"], PASSWORD_DEFAULT);
                            let query .= ", password=:password";
                        }
                    }

                    let query .= " WHERE id=:id";

                    let data = this->setData(data, model);

                    let status = this->db->execute(
                        query,
                        data
                    );

                    if (!is_bool(status)) {
                        let html .= this->saveFailed("Failed to update the user");
                    } else {
                        let html .= this->saveSuccess("User has been updated");
                    }
                }
            }
        }

        let html .= this->render(model);

        return html . "</div>";
    }

    public function index(string path)
    {
        var html, data = [], query, gfx;

        let gfx = new Gfx(this->settings, this->db);

        let html = this->header("Users") . "<div id='page-body'>";

        try {
            if (isset(_GET["delete"])) {
                if (!empty(_GET["delete"])) {
                    this->triggerDelete(_GET["delete"]);
                    let html .= this->info("User has been deleted");
                }
            }
    
            if (isset(_GET["recover"])) {
                if (!empty(_GET["recover"])) {
                    this->triggerRecover(_GET["recover"]);
                    let html .= this->info("User has been recovered");
                }
            }
    
            let query = "
                SELECT users.* FROM users 
                WHERE users.id IS NOT NULL";
            if (isset(_POST["q"])) {
                let query .= " AND users.username LIKE :query";
                let data["query"] = "%" . _POST["q"] . "%";
            }
    
            let query .= " ORDER BY users.username";
    
            let data = this->db->all(query, data);
                        
            if (count(data)) {
                let html .= gfx->searchBox(this->global_url);

                let html .= "
                <div class='box'>
                    <table>
                        <thead>
                            <tr>
                                <th>User</th>
                                <th class='buttons' width='120px'>" .
                                    gfx->buttonAdd(this->global_url . "/add", "Create a user") .
                                "</th>
                            </tr>
                        </thead>
                        <tbody>";
                    var item;
                    for item in data {
                        let html .= "<tr>
                            <td>" . item->username . "</td>
                            <td class='buttons'>" .
                                gfx->buttonEdit(this->global_url . "/edit/" . item->id, "Manage the user") .
                                gfx->buttonDelete(this->global_url . "/delete/" . item->id, "Delete the user") .
                            "</td>
                        </tr>";
                    }
                    let html .= "
                        </tbody>
                    </table>
                </div>";
            } else {
                let html .= "<h2><span>No users found</span></h2>";
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

    public function login()
    {
        var gfx, data, html = "";
        let gfx = new Gfx(this->settings, this->db);

        if (this->getUserId()) {
            this->redirect(this->urlAddKey("/"));
        }

        let html = "<div id='login'>";

        if (isset(_POST["login"])) {
            if (!this->validate(_POST, ["username", "password"])) {
                let html .= this->saveFailed("Missing required fields");
            } else {
                let data = this->db->get(
                    "SELECT id, password FROM users WHERE username=:USERNAME AND deleted_at IS NULL",
                    [
                        "USERNAME": _POST["username"]
                    ]
                );
                
                if (data) {
                    if (!password_verify(_POST["password"], data->password)) {
                        let html .= this->error("Invalid login");    
                    } else {
                        let _SESSION[this->settings->session_key] = data->id;
                        this->redirect(this->urlAddKey("/"));
                    }
                } else {
                    let html .= this->error("Invalid login");
                }
            }
        }

        return html . "
        <form class='box' method='post'>
            <div class='box-title'>Login</div>
            <div class='box-body'>" .
                gfx->text("Username", "username", "what your username?", "", true) .
                gfx->password("Password", "password", "what is your password?", "", true) .
            "</div>
            <div class='box-footer text-right'>" .
                gfx->buttonLogin() .
            "</div>
        </form></div>";
    }

    public function logout()
    {
        unset(_SESSION[this->settings->session_key]);
        this->redirect(this->urlAddKey("/locked"));
    }

    public function render(model, mode = "add")
    {
        var gfx;
        let gfx = new Gfx(this->settings, this->db);

        return "
        <form method='post' enctype='multipart/form-data'>
            <div class='tabs'>
                <div class='tabs-content'>
                    <div id='user-tab' class='row'>
                        <div class='col-full'>
                            <div class='box'>
                                <div class='box-body'>" .
                                gfx->text("Username", "username", "what is their username?", model->username, true) .
                                gfx->text("Nickname", "nickname", "what shall I call them?", model->nickname, true) .
                                gfx->password("Password", "password", "sssh, it is our secret!") .
                                gfx->password("Password check", "password_check", "same again please!") .
                                "</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>";
    }

    private function setData(data, model)
    {
        let data["username"] = _POST["username"];

        if (model->username != data["username"]) {
            var user;                        
            let user = this->db->get(
                "SELECT * FROM users WHERE username=:username",
                [
                    "username": data["username"]
                ]
            );
            if (user) {
                throw new \Exception("username already taken");
            }
        }

        let data["nickname"] = _POST["nickname"];
        let data["updated_by"] = this->getUserId();

        return data;
    }

    private function triggerDelete(string id)
    {
        this->db->execute(
            "UPDATE users SET deleted_at=NOW(), deleted_by=:UID WHERE id=:ID",
            [
                "UID": this->getUserId(),
                "ID": id
            ]
        );
    }

    private function triggerRecover(string id)
    {
        this->db->execute(
            "UPDATE users SET deleted_at=NULL, deleted_by=NULL WHERE id=:ID",
            [
                "ID": id
            ]
        );
    }
}