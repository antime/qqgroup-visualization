
const Koa = require("koa");
const KoaRouter = require("koa-router");
const KoaStatic = require("koa-static");
const Koa2Cors = require("koa2-cors");
const MSSQL = require("mssql");

const config = {
    user: 'sa',
    password: 'gushihao',
    server: 'localhost',
    database: 'QQQun'
};

const serverPort = 1239;

(async () => {
    try {
        let pool = await MSSQL.connect(config);
        let app = new Koa();
        let router = new KoaRouter();

        //跨域配置
        let cors = Koa2Cors({
            origin: function (ctx) {
                return "*";
            },
            exposeHeaders: ['WWW-Authenticate', 'Server-Authorization'],
            maxAge: 5,
            credentials: true,
            allowMethods: ['GET'],
            allowHeaders: ['Content-Type', 'Authorization', 'Accept'],
        });

        //QQ查询接口
        router.get('/qq/:id', async (ctx, next) => {
            let qqNum = Number(ctx.params.id);
            let result = await pool.request()
                            .input('QQNum', MSSQL.Int, qqNum)
                            .execute('queryByQQNum');
            ctx.body = result.recordsets;
        });
        //群查询接口（比较慢）
        router.get('/group/:id', async (ctx, next) => {
            let qunNum = Number(ctx.params.id);
            let result = await pool.request()
                            .input('QunNum', MSSQL.Int, qunNum)
                            .execute('queryByQunNum');
            ctx.body = result.recordsets;
        });

        app.use(cors).use(KoaStatic(__dirname + "/www")).use(router.routes()).use(router.allowedMethods());

        app.listen(serverPort);
        console.log("服务已经启动，工作在 " + serverPort + " 端口...");
    }
    catch (e) {
        console.error(e);
    }
})();





