import http from 'k6/http';
import { check } from 'k6';
export const options={vus:100,iterations:100};
export default function(){
 const token=__ENV.STUDENT_TOKEN; const slot=__ENV.SLOT_ID;
 if(!token||!slot) throw new Error('Set STUDENT_TOKEN and SLOT_ID for the race test');
 const r=http.post(`${__ENV.BASE_URL||'http://localhost:4000'}/api/appointments`,JSON.stringify({slotId:Number(slot)}),{headers:{'Content-Type':'application/json',Authorization:`Bearer ${token}`}});
 check(r,{'only one request can create the booking':x=>x.status===201||x.status===409});
}
