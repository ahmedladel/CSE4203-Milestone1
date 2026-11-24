import http from 'k6/http';
import { check, sleep } from 'k6';
export const options={vus:200,duration:'60s',thresholds:{http_req_duration:['p(95)<500']}};
export default function(){const r=http.get(`${__ENV.BASE_URL||'http://localhost:4000'}/api/slots`);check(r,{'availability responds 200':x=>x.status===200});sleep(1);}
