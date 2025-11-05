class ApiStatusCodes {
  static const Map<int, String> messages = {
    // Success (2xx)
    200: 'OK: Request was successful',
    201: 'Created: Resource created successfully',
    202: 'Accepted: Request has been accepted for processing',
    204: 'No Content: No content to send for this request',
    205: 'Reset Content: Reset content as per the request',
    206: 'Partial Content: Partial response sent',

    // Redirects (3xx)
    300: 'Multiple Choices',
    301: 'Moved Permanently',
    302: 'Found',
    303: 'See Other',
    304: 'Not Modified',
    307: 'Temporary Redirect',
    308: 'Permanent Redirect',

    // Client Errors (4xx)
    400: 'Bad Request',
    401: 'Unauthorized',
    402: 'Payment Required',
    403: 'Forbidden',
    404: 'Not Found',
    405: 'Method Not Allowed',
    406: 'Not Acceptable',
    408: 'Request Timeout',
    409: 'Conflict',
    410: 'Gone',
    411: 'Length Required',
    412: 'Precondition Failed',
    413: 'Payload Too Large',
    414: 'URI Too Long',
    415: 'Unsupported Media Type',
    416: 'Range Not Satisfiable',
    417: 'Expectation Failed',
    422: 'Unprocessable Entity',
    429: 'Too Many Requests',

    // Server Errors (5xx)
    500: 'Internal Server Error',
    501: 'Not Implemented',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
    504: 'Gateway Timeout',
    505: 'HTTP Version Not Supported',
    511: 'Network Authentication Required',
  };

  static String getMessage(int statusCode) {
    return messages[statusCode] ?? 'Unknown Status Code: $statusCode';
  }
}
