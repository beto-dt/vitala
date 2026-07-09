import { onRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { defineSecret } from 'firebase-functions/params';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { RtcTokenBuilder, RtcRole } from 'agora-token';

if (!getApps().length) initializeApp();
const db = getFirestore();

const AGORA_APP_ID = 'TU_APP_ID_DE_AGORA';
const AGORA_CERT = defineSecret('AGORA_CERT');
const TOKEN_TTL_SECONDS = 3600; // 1h: sobra para una consulta demo

/** Room code like VIT-4F2K (no 0/O/1/I). */
function genCode(): string {
    const chars = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
    let s = '';
    for (let i = 0; i < 4; i++) s += chars[Math.floor(Math.random() * chars.length)];
    return `VIT-${s}`;
}

export const createRoom = onRequest({ region: 'us-central1', cors: true }, async (req, res) => {
    if (req.method !== 'POST') {
        res.status(405).json({ error: 'method_not_allowed' });
        return;
    }
    const code = genCode();
    await db.doc(`rooms/${code}`).set({ createdAt: Timestamp.now(), status: 'open' });
    res.json({ code });
});

export const getRtcToken = onRequest(
    { region: 'us-central1', cors: true, secrets: [AGORA_CERT] },
    async (req, res) => {
        if (req.method !== 'POST') {
            res.status(405).json({ error: 'method_not_allowed' });
            return;
        }
        const { code, uid } = (req.body ?? {}) as Record<string, unknown>;
        if (typeof code !== 'string' || !/^VIT-[A-Z2-9]{4}$/.test(code) ||
            typeof uid !== 'number' || !Number.isInteger(uid) || uid < 1 || uid > 999999) {
            res.status(400).json({ error: 'bad_request' });
            return;
        }
        const room = await db.doc(`rooms/${code}`).get();
        if (!room.exists || room.data()?.status !== 'open') {
            res.status(404).json({ error: 'room_not_found' });
            return;
        }
        const now = Math.floor(Date.now() / 1000);
        const token = RtcTokenBuilder.buildTokenWithUid(
            AGORA_APP_ID,
            AGORA_CERT.value(),
            code,          // channel = room code
            uid,
            RtcRole.PUBLISHER,
            now + TOKEN_TTL_SECONDS,
            now + TOKEN_TTL_SECONDS,
        );
        res.json({ appId: AGORA_APP_ID, channel: code, uid, token });
    },
);

/** Demo sandbox: nightly cleanup of rooms. */
export const resetDemo = onSchedule(
    { schedule: '0 5 * * *', timeZone: 'America/Guayaquil', region: 'us-central1' },
    async () => {
        const snap = await db.collection('rooms').get();
        const batch = db.batch();
        snap.docs.forEach((d) => batch.delete(d.ref));
        await batch.commit();
        console.log(`resetDemo: deleted ${snap.size} rooms`);
    },
);
