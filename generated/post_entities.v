module main

import time

struct Post {

    id int [primary; sql: serial]
    title string 
    body string 
    created_at time.Time [sql_type: 'DATETIME']
    updated_at time.Time [sql_type: 'DATETIME']
    is_blocked bool 
    author Author 
}
