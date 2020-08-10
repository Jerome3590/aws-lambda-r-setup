aws_lambda_r <- function(input_json) {
    output_json <- '{"message": "Cannot create output JSON"}'
    tryCatch({
        input_lst <- from_json(input_json)
        request_id <- input_lst$request_id[1]
        output_lst <- list(
            result_id = request_id,
            result_lst = list(a = 1, b = 2:4),
            result_dbl = 1:10 / 2,
            message = NULL
        )
        output_json <- to_json(output_lst)
    }, error = function(e) {
        output_json <<- paste0('{"message": "', e$message, '"}')
    })
    output_json
}